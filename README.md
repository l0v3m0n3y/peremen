# peremen
api for peremen.app browser extension. Наша команда на практике знает, как важно иметь безопасную связь с домом. Поэтому мы создали VPN Перемен. Он возвращает доступ к российским сервисам
# main
```swift
import Foundation
import peremen
let client = Peremen()

do {
    let emailInfo = try await client.requestCode(email: "email")
    print(emailInfo)
} catch {
    print("Error: \(error)")
}
```

# Launch (your script)
```
swift run
```
