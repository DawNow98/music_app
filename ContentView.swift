//
//  ContentView.swift
//  MusicApp
//
//  Created by Dawid Nowacki on 03/02/2024.
//

import SwiftUI
import CoreData
import AVKit

struct ContentView: View {
    
    @State var audioFileName = "01 #1 - WIELKOMIEJSKA BEZSENNOŚĆ"
    
    @State private var player: AVAudioPlayer?
    @State private var tytul: [String] = ["01 #1 - WIELKOMIEJSKA BEZSENNOŚĆ", "02 1-800-OŚWIECENIE", "03 #2 - GRZĘZNĄĆ W CISZY", "04 Cichosza", "05 #3 - TUTTO PASSA", "06 Gelato", "07 TU RADIO MARMUR #1", "08 Może To Coś Zmieni_", "09 Pakiet Platinium", "10 #4 - NESESER", "11 Makarena Freestyle", "12 #5 - GŁOSÓWKI DO REDAKCJI", "13 Mix Sałat", "14 #6 - DOBRY JAK DOBRY", "15 Codziennie", "16 #7 - PRACA DOMOWA", "17 1000 Dni Freestyle", "18 TU RADIO MARMUR #2", "19 Nametag", "20 #8 - KĄCIK KONSPIRACYJNY", "21 Całe Lata", "22 #9 - SŁYSZY PAN_", "23 Niedziela", "24 #10 - JESTEM", "25 Main Stage Freestyle", "26 #11 - LUSTERKO WSTECZNE", "27 EINECEIWŚO 008-1"]
    
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    @State private var animationContent: Bool = false
    
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .topLeading, endPoint: .bottom)
                            .opacity(0.75)
                            //.opacity(animationContent ? 1 : 0)
                    }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    GeometryReader {_ in
                        Image("COVER")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding()
                    }
                    
                    .frame(height: size.width - 50)
                    .padding(.vertical, size.height < 700 ? 10 : 30)
                    
                    PlayerView(size)
                    Spacer()
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10: 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .clipped()
            }
            .ignoresSafeArea(.container, edges: .all)
        }
        
        .onAppear(perform: {
            setupAudio()
        })
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
        updateProgress()
        }
    }
    
    private func setupAudio() {
        
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    private func playAudio() {
        player?.play()
        isPlaying = true
    }
    private func pauseAudio() {
        player?.pause()
        isPlaying = false
    }
    private func stopAudio() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
    }
    private func updateProgress() {
        guard let player = player else { return }
        currentTime = player.currentTime
    }
    private func seekAudio(to time: TimeInterval) {
        player?.currentTime = time
    }
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
    private func playNextSong() {
        
        guard let currentIndex = tytul.firstIndex(of: audioFileName) else { return }
        
        var nextIndex = (currentIndex + 1) % tytul.count
        
        //sprawdzenie czy jesteśmy na koncu tablicy - jeśli tak wracamy na początek
        if nextIndex == 0 && currentIndex != 0 {
            nextIndex = 0
        }
        
        if isPlaying {
            stopAudio()
        }
        
        audioFileName = tytul[nextIndex]
        setupAudio()
        playAudio()
    }
    private func playPreviousSong() {
        
        guard let currentIndex = tytul.firstIndex(of: audioFileName) else { return }
        
        var previousIndex = (currentIndex - 1) % tytul.count
        
        //sprawdzenie czy jesteśmy na poczatku tablicy - jeśli tak wracamy do punktu 0
        if previousIndex < 0 {
            previousIndex = tytul.count - 1
        }
        
        if isPlaying {
            stopAudio()
        }
        
        audioFileName = tytul[previousIndex]
        setupAudio()
        playAudio()
    }
    
    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        GeometryReader{
            let size = $0.size
            let spacing = size.height * 0.04
            let trimmedFileName = String(audioFileName.dropFirst(3))
            
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 4) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(String(trimmedFileName))
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Taco Hemingway")
                                .foregroundStyle(Color.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(Color.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                )
                        })
                        
                    }
                    
                    Slider(value: Binding(get: {
                        currentTime
                    }, set: { newValue in
                        seekAudio(to: newValue)
                    }), in: 0...totalTime)
                    .foregroundStyle(Color.white)
                    .tint(Color.red)
                    
                    HStack {
                        Text(timeString(time: currentTime))
                        Spacer()
                        Text(timeString(time: totalTime))
                        
                    }
                }
                .frame(height: size.height / 2.5, alignment: .topLeading)
                .padding()
                HStack(spacing: size.width * 0.18) {
                    Button(action: {
                        playPreviousSong()
                    }, label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                            .onTapGesture {
                                playPreviousSong()
                            }
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                            .onTapGesture {
                                isPlaying ? pauseAudio() : playAudio()
                            }
                    })
                    
                    Button(action: {
                        playNextSong()
                    }, label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                            .onTapGesture {
                                playNextSong()
                            }
                    })
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                
                VStack(spacing: spacing) {
                    HStack(spacing: 15) {
                        Image(systemName: "speaker.fill")
                        
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .light)
                            .frame(height: 5)
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    HStack(alignment: .top, spacing: size.width * 0.18, content: {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "quote.bubble")
                                .font(.title2)
                        })
                        
                        VStack(spacing: 6, content: {
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "airpodspro.chargingcase.wireless.fill")
                                    .font(.title2)
                            })
                            Text("Hi")
                            Text("Airpods")
                                .font(.caption)
                                .foregroundStyle(Color.white)
                        })
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                        })
                        
                        
                    })
                    .foregroundStyle(Color.white)
                    .padding(.top, spacing)
                    .opacity(0.2)
                }
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView(expandSheet: .constant(true), animation: Namespace().wrappedValue)
            .preferredColorScheme(.dark)
    }
}

extension View {
    var deviceCornerRadius: CGFloat {
        
        let key = "_displayCornerRadius"
        
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen{
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius
            }
            return 0
        }
        return 0
    }
}
