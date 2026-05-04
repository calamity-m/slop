# Sed Snippets

## Replace pattern in file

```
sed -i 's/<@old>/<@new>/g' <@file>
```

## Delete lines matching pattern

```
sed -i '/<@pattern>/d' <@file>
```
