# peremen
api for peremen.app browser extension. Наша команда на практике знает, как важно иметь безопасную связь с домом. Поэтому мы создали VPN Перемен. Он возвращает доступ к российским сервисам
# main
```swift
import Foundation
import peremen
let client = Peremen()

do {
    let email_info = try await client.request_code("email")
    print(email_info)
} catch {
    print("Error: \(error)")
}
```

# Launch (your script)
```
swift run
```
