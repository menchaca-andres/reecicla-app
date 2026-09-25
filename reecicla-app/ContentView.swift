import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Mi primera app")
                .font(.largeTitle)
                .bold()

            Text("¡Hola desde iOS!")

            Button("Presióname") {
                print("Botón presionado")
            }
        }
        .padding()
    }
}
