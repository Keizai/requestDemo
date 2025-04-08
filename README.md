## 🔐 AES 加解密排查记录

### ✅ 解密结果

```json
{
  "message": "Por favor ingrese el número de teléfono",
  "status": "600",
  "timestamp": "2025-04-08T00:40:38.125"
}
```

**提示信息：**

> Por favor ingrese el número de teléfono（请填写手机号码）

---

### 🧩 分析结论

- ✅ 解密成功
- ⚠️ 返回内容提示未填写手机号，说明 **加密参数中的手机号没有被正确加密或传入服务端时丢失**
- 📋 已对 token 和参数的生成过程增加日志输出，目前未发现明显错误

---

### 🔍 加密日志输出

#### 🧷 Token 加密

```
Token before encryption:
["uuId": "", "version": "1.0.0", "userId": "", "idfa": "", "sourceChannel": "", "packageName": "com.mexico.universal", "adid": "", "idfv": ""]

=== Token Encryption ===
Original string to encrypt:
{"userId":"","uuId":"","version":"1.0.0","adid":"","idfa":"","sourceChannel":"","idfv":"","packageName":"com.mexico.universal"}

Key length: 32
IV length: 16

Encrypted result (base64):
E4OEx3oeeJem+B/b8JmGF3WETNAbUmlRlFhZV8FBZBsnvZYnGAi3qUerEhsPEIJtPSKH5+Y0AHwHshDH0TiJN7QdhjApGSx2clikzBi3X1aAThMLCHS0QpqMWTDWEaY6AoLnaKPUs9ySrcM+DiWGBTaDW9ZFYEm5eQaGqFpqD9w=

=== End Token Encryption ===
```

#### 📞 参数加密（手机号）

```
Parameters before encryption:
["type": "text", "mobile": "5512345678"]

=== Parameters Encryption ===
Original string to encrypt:
{"mobile":"5512345678","type":"text"}

Key length: 16
IV length: 16

Encrypted result (base64):
z8mUhwNLPF0rhmWQPboqP/bU/fFeUsSzdn88ci6Wpd0h7xx3p21fYaz5AyGrH7oc

=== End Parameters Encryption ===
```

---
