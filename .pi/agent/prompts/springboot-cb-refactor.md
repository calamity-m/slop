---
description: Refactor a complex and dynamic Springboot CriteriaBuilder implementation into a more simple raw parser and AST
argument-hint: "<query>"
---

# Goal

Replace complex Spring `CriteriaBuilder` / `Specification` usage with a small, explicit query compiler.

This is **not** a general SQL builder.

The system should:

- Accept JSON-defined queries
- Support nested AND/OR groups
- Support hidden joins
- Support field aliases (API names != database names)
- Generate parameterized SQL
- Be Oracle-friendly
- Avoid `(:p IS NULL OR ...)`
- Avoid `COALESCE/NVL` optional-filter tricks
- Avoid CriteriaBuilder-generated SQL surprises
- Retain strict control over allowed fields, joins and operators

---

# Architecture

```text
JSON Query
    ↓
Parser
    ↓
AST
    ↓
Validator
    ↓
SQL Renderer
    ↓
SqlFragment
    ↓
NamedParameterJdbcTemplate
```

---

# Example JSON

```json
{
  "operator": "and",
  "conditions": [
    {
      "field": "status",
      "operator": "eq",
      "value": "ACTIVE"
    },
    {
      "operator": "or",
      "conditions": [
        {
          "field": "customerName",
          "operator": "contains",
          "value": "smith"
        },
        {
          "field": "customerName",
          "operator": "contains",
          "value": "john"
        }
      ]
    }
  ]
}
```

---

# AST

```java
sealed interface QueryNode
    permits GroupNode, PredicateNode {
}
```

```java
record GroupNode(
    LogicalOperator operator,
    List<QueryNode> conditions
) implements QueryNode {
}
```

```java
record PredicateNode(
    String field,
    Operator operator,
    JsonNode value
) implements QueryNode {
}
```

```java
enum LogicalOperator {
    AND,
    OR
}
```

```java
enum Operator {
    EQ,
    NE,
    GT,
    GTE,
    LT,
    LTE,
    IN,
    CONTAINS,
    IS_NULL,
    IS_NOT_NULL
}
```

---

# Join Registry

All joins are explicitly defined.

The user can never provide join information.

```java
record JoinDef(
    String name,
    String sql
) {
}
```

```java
Map<String, JoinDef> JOINS = Map.of(

    "customer",
    new JoinDef(
        "customer",
        """
        LEFT JOIN CUSTOMER c
            ON c.ID = o.CUSTOMER_ID
        """
    ),

    "account",
    new JoinDef(
        "account",
        """
        LEFT JOIN ACCOUNT a
            ON a.ID = o.ACCOUNT_ID
        """
    )
);
```

---

# Field Registry

All API fields must be whitelisted.

API names do not need to match database names.

```java
record FieldDef<T>(
    String apiName,
    String sqlExpression,
    Class<T> javaType,
    Set<Operator> allowedOperators,
    Set<String> requiredJoins
) {
}
```

Example fields:

```java
Map<String, FieldDef<?>> FIELDS = Map.of(

    "orderId",
    new FieldDef<>(
        "orderId",
        "o.ID",
        Long.class,
        Set.of(EQ, IN),
        Set.of()
    ),

    "status",
    new FieldDef<>(
        "status",
        "o.STATUS",
        String.class,
        Set.of(EQ, IN),
        Set.of()
    ),

    "createdTime",
    new FieldDef<>(
        "createdTime",
        "o.CREATED_TIME",
        Instant.class,
        Set.of(GTE, LTE),
        Set.of()
    ),

    "customerName",
    new FieldDef<>(
        "customerName",
        "c.NAME",
        String.class,
        Set.of(EQ, CONTAINS),
        Set.of("customer")
    ),

    "accountNumber",
    new FieldDef<>(
        "accountNumber",
        "a.ACCOUNT_NUMBER",
        String.class,
        Set.of(EQ, IN),
        Set.of("account")
    )
);
```

---

# Render Context

Tracks bind variables and required joins.

```java
final class RenderContext {

    private int paramCounter = 0;

    private final Map<String, Object> params =
        new LinkedHashMap<>();

    private final Set<String> requiredJoins =
        new LinkedHashSet<>();

    String bind(Object value) {

        String name = "p" + (++paramCounter);

        params.put(name, value);

        return ":" + name;
    }

    void requireJoins(Set<String> joins) {
        requiredJoins.addAll(joins);
    }

    Map<String, Object> params() {
        return params;
    }

    Set<String> requiredJoins() {
        return requiredJoins;
    }
}
```

---

# SQL Fragment

Represents a rendered SQL piece.

```java
record SqlFragment(
    String sql,
    Map<String, Object> params,
    Set<String> requiredJoins
) {
}
```

---

# SQL Renderer

```java
final class SqlRenderer {

    private final FieldRegistry fields;

    SqlFragment render(QueryNode node) {

        RenderContext ctx = new RenderContext();

        String sql = renderNode(node, ctx);

        return new SqlFragment(
            sql,
            ctx.params(),
            ctx.requiredJoins()
        );
    }

    private String renderNode(
        QueryNode node,
        RenderContext ctx
    ) {

        return switch (node) {

            case GroupNode group ->
                renderGroup(group, ctx);

            case PredicateNode predicate ->
                renderPredicate(predicate, ctx);
        };
    }
}
```

---

# Group Rendering

```java
private String renderGroup(
    GroupNode group,
    RenderContext ctx
) {

    if (group.conditions().isEmpty()) {
        throw new QueryValidationException(
            "Empty condition groups are not allowed"
        );
    }

    String joiner = switch (group.operator()) {
        case AND -> " AND ";
        case OR -> " OR ";
    };

    return group.conditions()
        .stream()
        .map(node -> renderNode(node, ctx))
        .collect(Collectors.joining(
            joiner,
            "(",
            ")"
        ));
}
```

---

# Predicate Rendering

```java
private String renderPredicate(
    PredicateNode predicate,
    RenderContext ctx
) {

    FieldDef<?> field =
        fields.getRequired(predicate.field());

    if (!field.allowedOperators()
        .contains(predicate.operator())) {

        throw new QueryValidationException(
            "Operator not allowed"
        );
    }

    ctx.requireJoins(field.requiredJoins());

    return switch (predicate.operator()) {

        case EQ ->
            field.sqlExpression()
                + " = "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case NE ->
            field.sqlExpression()
                + " <> "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case GT ->
            field.sqlExpression()
                + " > "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case GTE ->
            field.sqlExpression()
                + " >= "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case LT ->
            field.sqlExpression()
                + " < "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case LTE ->
            field.sqlExpression()
                + " <= "
                + ctx.bind(
                    coerce(field, predicate.value())
                );

        case CONTAINS -> {

            String value =
                escapeLike(
                    coerce(field, predicate.value())
                        .toString()
                        .toLowerCase()
                );

            yield "LOWER("
                + field.sqlExpression()
                + ") LIKE "
                + ctx.bind("%" + value + "%")
                + " ESCAPE '\\'";
        }

        case IS_NULL ->
            field.sqlExpression() + " IS NULL";

        case IS_NOT_NULL ->
            field.sqlExpression() + " IS NOT NULL";

        case IN ->
            renderIn(field, predicate.value(), ctx);
    };
}
```

---

# IN Rendering

```java
private String renderIn(
    FieldDef<?> field,
    JsonNode value,
    RenderContext ctx
) {

    List<Object> values =
        coerceList(field, value);

    if (values.isEmpty()) {
        throw new QueryValidationException(
            "IN list cannot be empty"
        );
    }

    if (values.size() > 1000) {
        throw new QueryValidationException(
            "IN list too large"
        );
    }

    return field.sqlExpression()
        + " IN ("
        + values.stream()
            .map(ctx::bind)
            .collect(Collectors.joining(", "))
        + ")";
}
```

---

# LIKE Escaping

Required for `%` and `_`.

```java
private static String escapeLike(
    String value
) {

    return value
        .replace("\\", "\\\\")
        .replace("%", "\\%")
        .replace("_", "\\_");
}
```

---

# Final Query Assembly

```java
SqlFragment fragment =
    renderer.render(query);
```

Render joins:

```java
String joinSql =
    fragment.requiredJoins()
        .stream()
        .map(JOINS::get)
        .map(JoinDef::sql)
        .collect(Collectors.joining("\n"));
```

Final SQL:

```java
String sql = """
    SELECT /*+ INDEX(o IDX_ORDERS_CREATED_TIME) */
        o.*
    FROM ORDERS o
    %s
    WHERE %s
    ORDER BY
        o.CREATED_TIME DESC,
        o.ID DESC
    OFFSET :offset ROWS
    FETCH NEXT :limit ROWS ONLY
    """.formatted(
        joinSql,
        fragment.sql()
    );
```

Parameters:

```java
Map<String, Object> params =
    new LinkedHashMap<>(fragment.params());

params.put("offset", 0);
params.put("limit", 50);
```

---

# Example Output

Generated SQL:

```sql
SELECT /*+ INDEX(o IDX_ORDERS_CREATED_TIME) */
    o.*
FROM ORDERS o

LEFT JOIN CUSTOMER c
    ON c.ID = o.CUSTOMER_ID

WHERE (
    o.STATUS = :p1
    AND
    LOWER(c.NAME) LIKE :p2 ESCAPE '\'
)

ORDER BY
    o.CREATED_TIME DESC,
    o.ID DESC

OFFSET :offset ROWS
FETCH NEXT :limit ROWS ONLY
```

Parameters:

```java
{
    p1 = "ACTIVE",
    p2 = "%smith%",
    offset = 0,
    limit = 50
}
```

---

# Executing the Query

Prefer `NamedParameterJdbcTemplate` for this path.

It matches the compiler output nicely:

```java
record SqlQuery(
    String sql,
    Map<String, Object> params
) {}
```

```java
SqlQuery query = sqlBuilder.build(request);
```

Execute into a DTO:

```java
List<OrderSearchResult> results =
    namedParameterJdbcTemplate.query(
        query.sql(),
        query.params(),
        DataClassRowMapper.newInstance(OrderSearchResult.class)
    );
```

Example DTO:

```java
public record OrderSearchResult(
    Long orderId,
    String status,
    Instant createdTime,
    String customerName
) {}
```

Your SQL aliases should match the record fields:

```sql
SELECT
    o.ID AS orderId,
    o.STATUS AS status,
    o.CREATED_TIME AS createdTime,
    c.NAME AS customerName
FROM ORDERS o
...
```

## EntityManager option

Use this only if you need to stay closer to JPA:

```java
Query query = entityManager.createNativeQuery(sql);

params.forEach(query::setParameter);

List<Object[]> rows = query.getResultList();
```

Then map manually:

```java
List<OrderSearchResult> results =
    rows.stream()
        .map(row -> new OrderSearchResult(
            ((Number) row[0]).longValue(),
            (String) row[1],
            ((Timestamp) row[2]).toInstant(),
            (String) row[3]
        ))
        .toList();
```

## Recommendation

Use:

```text
SQL compiler -> NamedParameterJdbcTemplate -> DTO record
```

Avoid mapping dynamic native search results back into managed JPA entities unless you specifically need entity lifecycle behaviour.

---

# Security Rules

Mandatory:

- Values are always bind parameters.
- Field names are registry lookups.
- Operators are enums.
- Sort fields are registry lookups.
- Sort directions are enums.
- Join definitions are registry lookups.
- SQL hints are predefined.
- LIKE values are escaped.
- IN values are individually bound.
- Unknown fields are rejected.
- Unsupported operators are rejected.

Never allow user-controlled:

- SQL expressions
- column names
- table names
- aliases
- joins
- hints
- functions
- order by expressions

---

# Validation Rules

Recommended limits:

```text
Maximum depth: 10

Maximum conditions: 100

Maximum IN values: 1000

Maximum page size: 500
```

Reject:

```text
Unknown field

Unknown operator

Empty condition groups

Unsupported operator for field

Type mismatch
```

---

# Recommended Migration Plan

Phase 1

- Add AST
- Add parser
- Add validator
- Add golden tests

Phase 2

- Add SQL renderer
- Keep existing CriteriaBuilder implementation

Phase 3

- Run both implementations in tests

Phase 4

- Switch one endpoint to native SQL

Phase 5

- Gradually migrate remaining search endpoints

---

# Non-Goals

Do not build:

- jOOQ clone
- general SQL builder
- arbitrary SQL execution engine
- arbitrary joins
- arbitrary functions
- user-defined expressions

Keep the DSL small and explicit.

The goal is a controlled query compiler, not a database language.

# Query

$@
