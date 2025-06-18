//
//  ContentView.swift
//  EstudePlus
//
//  Created by Ângelo Mendes on 17/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = EstudoMaisViewModel()
    @State private var showingCadastroModal = false
    
    var body: some View {
        NavigationView {
            VStack {
//                Desempacota o usuário com segurança
                if let usuario = viewModel.usuario {
//                    Criar um Biding temporário para a propriedade objetivo do usuário
                    let objetivoBiding = Binding<ObjetivoEstudo>(
                        get: { usuario.objetivo },
                        set: { newValue in
//                        Quando o picker muda, chamamos a função no ViewModel
//                         Para atualizar o usuário e salvar os dados
                            viewModel.criarOuAtualizarUsuario(nome: usuario.nome, objetivo: newValue)
                        }
                    )
                    
                    Text("Bem-vindo(a), \(usuario.nome)!")
                        .font(.title)
                        .padding()
                    
                    Picker("Objetivo", selection: objetivoBiding) {
                        ForEach(ObjetivoEstudo.allCases) { objetivo in
                            Text(objetivo.rawValue).tag(objetivo)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    
                    ProgressView(value: viewModel.progressoSemanal) {
                        Text("Progresso Semanal:")
                    } currentValueLabel: {
                        Text(String(format: "%.0f%%", viewModel.progressoSemanal * 100))
                    }
                    .padding()
                    
                    Text("Horas Previstas: \(String(format: "%.1f", viewModel.horasTotaisPrevistasSemana))h")
                    Text("Horas Estudadas: \(String(format: "%.1f", viewModel.horasEstudadasSemana))h")
                        .padding(.bottom)
                    
                    List {
                        Section(header: Text("Tarefas de hoje")) {
                            if viewModel.tarefasDoDia.isEmpty {
                                Text("Nenhuma tarefa para hoje. 🎉")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.tarefasDoDia) { tarefa in
                                    TarefaRowView(tarefa: tarefa) {
                                        viewModel.marcarTarefaConcluida(tarefa)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Bem-vindo(a) ao Estudo+!")
                        .font(.largeTitle)
                        .padding()
                    
                    Button("Começar agora") {
                        showingCadastroModal = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Estude+")
            .onAppear {
                viewModel.setupDailyTasks()
                viewModel.calculateWeeklyProgress()
            }
            .sheet(isPresented: $showingCadastroModal) {
                CadastroUsuarioView(viewModel: viewModel, isPresented: $showingCadastroModal)
            }
        }
    }
}

#Preview {
    ContentView()
}
