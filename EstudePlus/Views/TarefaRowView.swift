//
//  TarefaRowView.swift
//  EstudePlus
//
//  Created by Ângelo Mendes on 18/06/25.
//

import SwiftUI

struct TarefaRowView: View {
    let tarefa: TarefaEstudo
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: tarefa.concluida ? "checkmark.circle.fill" : "circle")
                .foregroundColor(tarefa.concluida ? .green : .gray)
                .onTapGesture {
                    onToggleCompletion()
                }
            
            VStack(alignment: .leading) {
                Text(tarefa.titulo)
                    .font(.headline)
                    .strikethrough(tarefa.concluida) // Risca o texto se concluido
                Text(tarefa.descricao)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Previsão: \(tarefa.dataFormatada)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(String(format: "%.1f", tarefa.horasEstimadas))h")
                .font(.footnote)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(5)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TarefaRowView(tarefa: TarefaEstudo(titulo: "Revisar Matemática", descricao: "Geometria analítica", data: Date(), concluida: false, horasEstimadas: 2.0)) {
        print("Tarefa marcada/desmarcada")
    }
    .padding()
}
