Dart 代码：
```dart
void main() {
  print('Hello, MD Preview!');
}

class User {
  final String name;
  User(this.name);
}
```

Python 代码：
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

SQL 代码：
```sql
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id
ORDER BY post_count DESC;
```
