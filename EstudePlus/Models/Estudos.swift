//
//  Estudos.swift
//  EstudePlus
//
//  Created by Ângelo Mendes on 17/06/25.
//

import Foundation

//MARK: - Objetivo de Estudo
enum ObjetivoEstudo: String, CaseIterable, Identifiable, Codable {
    case enem = "ENEM"
    case concurso = "Concurso Público"
    case faculdade = "Faculdade"
    case certificacaoTI = "Certificação de TI"
    case ourtos = "Outros"
    
    var id: String { self.rawValue }
}

//MARK: - Tarefa de Estudo
struct TarefaEstudo: Identifiable, Codable {
    let id: UUID
    var titulo: String
    var descricao: String
    var data: Date
    var concluida: Bool = false
    var horasEstimadas: Double // Para conogramas mais precisos
    
    init(id: UUID = UUID(), titulo: String, descricao: String, data: Date, concluida: Bool = false, horasEstimadas: Double) {
        self.id = id
        self.titulo = titulo
        self.descricao = descricao
        self.data = data
        self.concluida = concluida
        self.horasEstimadas = horasEstimadas
    }
    
    var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: data)
    }
}

//MARK: - Cronograma
struct Cronograma: Identifiable, Codable { // Adicionado Codable aqui
    let id: UUID // Para Codable, é melhor declarar como 'let'
    
    var dataCriacao: Date
    var horasDisponiveisPorDia: [DayOfWeek: Double] // Ex: [ .monday: 3.0, .tuesday: 2.5 ]
    var tarefas: [TarefaEstudo] = []

    init(id: UUID = UUID(), dataCriacao: Date, horasDisponiveisPorDia: [DayOfWeek : Double], tarefas: [TarefaEstudo] = []) {
        self.id = id
        self.dataCriacao = dataCriacao
        self.horasDisponiveisPorDia = horasDisponiveisPorDia
        self.tarefas = tarefas
    }
}

// Enum para os dias da semana
enum DayOfWeek: String, CaseIterable, Identifiable, Codable {
    case sunday = "Domingo"
    case monday = "Segunda-feira"
    case tuesday = "Terça-feira"
    case wednesday = "Quarta-feira"
    case thursday = "Quinta-feira"
    case friday = "Sexta-feira"
    case saturday = "Sábado"
    
    var id: String { self.rawValue }
    
    //    REtorna o índice numérico do dia da semana (1 oara domingo, 2 para segunda, etc)
    var calendarIndex: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

// MARK: - Usuário
struct Usuario: Identifiable, Codable {
    var id: UUID
    
    var nome: String
    var objetivo: ObjetivoEstudo
    var cronogramas: [Cronograma] = []
    var historicoDiario: [Date: Double] = [:] // Horas estudadas por dia
    
    init(id: UUID = UUID(), nome: String, objetivo: ObjetivoEstudo, cronogramas: [Cronograma] = [], historicoDiario: [Date: Double] = [:]) {
        self.id = id
        self.nome = nome
        self.objetivo = objetivo
        self.cronogramas = cronogramas
        self.historicoDiario = historicoDiario
    }
}

// MARK: - Mock Data (Para facilitar o teste)
extension TarefaEstudo {
    static var mockTarefas: [TarefaEstudo] {
        [
            TarefaEstudo(titulo: "Revisar Álgebra Linear", descricao: "Capítulos 1-3", data: Date().addingTimeInterval(86400 * 1), horasEstimadas: 2.0), // Amanhã
            TarefaEstudo(titulo: "Estudar Português", descricao: "Gramática e Regência", data: Date().addingTimeInterval(86400 * 2), horasEstimadas: 1.5), // Depois de amanhã
            TarefaEstudo(titulo: "Resolver questões de Lógica", descricao: "Concurso INSS", data: Date().addingTimeInterval(86400 * 3), horasEstimadas: 2.0),
            TarefaEstudo(titulo: "Ler Artigo Científico", descricao: "Sobre AI e Ética", data: Date().addingTimeInterval(86400 * 4), horasEstimadas: 1.0)
        ]
    }
}
