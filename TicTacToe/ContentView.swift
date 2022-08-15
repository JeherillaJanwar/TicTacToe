import SwiftUI

struct ContentView: View {
    struct ViewState {
        var game = TicTacToe(startingPlayer: .x)
        var isPVE = true
        var difficulty = TicTacToe.Difficulty.medium
        var disableGrid = true
        var willReset = false
    }
    
    @State private var state = ViewState()
    
    var body: some View {
        VStack {
            Text(displayedMessage)
                .font(.title2)
                .bold()
            Text("Made by Ishaan Sharma")
                .font(.caption)
                .foregroundColor(.red)
            
            GeometryReader { bounds in
                let width = bounds.size.width
                let height = bounds.size.height
                GridView(state: $state,
                         lineWidth: 0.02 * min(width, height))
                .onChange(of: state.difficulty) { _ in
                    state.willReset = true
                }
                .padding(0.1 * min(width, height))
                .frame(width: width,
                       height: height)
                
            }
            
            HStack {
                styledButton(systemName: state.isPVE ? "person" : "person.2") {
                    state.isPVE.toggle()
                    state.willReset = true
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Picker("Difficulty", selection: $state.difficulty) {
                    ForEach(TicTacToe.Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue.capitalized)
                            .tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 200)
                .opacity(state.isPVE ? 1 : 0)
                .animation(.default, value: state.isPVE)
                
                Spacer()
                
                styledButton(systemName: "arrow.counterclockwise") {
                    state.willReset = true
                }
                .foregroundColor(.red)
            }
        }
        .padding()
#if os(macOS)
        .frame(minWidth: 350,
               minHeight: 400)
#endif
    }
    
    private var displayedMessage: String {
        if state.game.hasNotEnded {
            guard !state.disableGrid else { return "..." }
            return state.isPVE ? "Your turn!" : "Player \(state.game.currentPlayer)"
        }
        // The game has ended. Check for draws first.
        guard state.game.hasWinner else { return "Draw!" }
        if state.isPVE {
            switch state.game.currentPlayer {
            case .x:
                return "You won!"
            case .o:
                return "You lost!"
            }
        }
        return "Player \(state.game.currentPlayer) won!"
    }
    
    private func styledButton(systemName: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .symbolVariant(.fill.circle)
                .symbolRenderingMode(.multicolor)
                .font(.title)
        }
        .buttonStyle(.borderless)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
        
    }
}
