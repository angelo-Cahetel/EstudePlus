//
//  CadastroUsuarioView.swift
//  EstudePlus
//
//  Created by Ângelo Mendes on 18/06/25.
//

import SwiftUI

struct CadastroUsuarioView: View {
    @ObservedObject var viewModel: EstudoMaisViewModel
    @Binding var isPresented: Bool
    
    @State private var nome: String = ""
    @State private var objetivoSelecionado:  ObjetivoEstudo = .faculdade
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Seus Dados")) {
                    TextField("Seu nome", text: $nome)
                    Picker("Qual seu objetivo de estudo?", selection: $objetivoSelecionado) {
                        ForEach(ObjetivoEstudo.allCases) { objetivo in
                            Text(objetivo.rawValue).tag(objetivo)
                        }
                    }
                }
                Button("Salvar e começar") {
                    viewModel.criarOuAtualizarUsuario(nome: nome, objetivo: objetivoSelecionado)
                    isPresented = false
                }
            }
            .navigationTitle("Primeiro Acesso")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    CadastroUsuarioView(viewModel: EstudoMaisViewModel(), isPresented: .constant(true))
}
