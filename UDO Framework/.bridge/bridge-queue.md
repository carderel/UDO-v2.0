# Bridge Queue

This file is the communication channel between bridge agents. Both agents append requests and responses here.

**Rules:**
- NEVER overwrite — always APPEND (HS-UDO-009)
- Follow the format in `templates/bridge-request.md` and `templates/bridge-response.md`
- Request IDs increment sequentially: REQ-0001, REQ-0002, etc.
- Full protocol: see `BRIDGE-PROTOCOL.md`

---

<!-- Requests and responses go below this line -->
