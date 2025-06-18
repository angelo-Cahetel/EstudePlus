//
//  ObservableObject.swift
//  EstudePlus
//
//  Created by Ângelo Mendes on 17/06/25.
//

import Foundation
import Combine
import SwiftUI // Para usar @Published

class EstudoMaisViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var cronogramaAtual: Cronograma?
    @Published var tarefasDoDia: [TarefaEstudo] = []
    @Published var horasTotaisPrevistasSemana: Double = 0.0
    @Published var horasEstudadasSemana: Double = 0.0
    @Published var progressoSemanal: Double = 0.0 // 0.0 a 1.0
    
    init() {
        //        carregar dados salvos ou criar um usuário inicial para demonstração
        loadUserData()
        setupDailyTasks()
        calculateWeeklyProgress()
    }
    
    //    MARK: - Simulação de carregamento/Criação de Usuário
    private func loadUserData() {
        //        Simular um usuário existente ou criar um novo
        if let storeUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decoderUser = try? JSONDecoder().decode(Usuario.self, from: storeUser) {
            self.usuario = decoderUser
        } else {
            //                Usuário padrão para o MVP
            self.usuario = Usuario(nome: "Estudante", objetivo: .faculdade)
            setupInitialCronograma()
            saveUserData()
        }
        self.cronogramaAtual = usuario?.cronogramas.first // Pega o primeiro cronograma
    }
    
    private func saveUserData() {
        if let encodedUser = try? JSONEncoder().encode(usuario) {
            UserDefaults.standard.set(encodedUser, forKey: "currentUser")
        }
    }
    
//    MARK: - Cadastro/Atualização de Usuário
    func criarOuAtualizarUsuario(nome: String, objetivo: ObjetivoEstudo) {
        if var usuarioExistente = usuario {
            usuarioExistente.nome = nome
            usuarioExistente.objetivo = objetivo
            self.usuario = usuarioExistente
        } else {
            self.usuario = Usuario(nome: nome, objetivo: objetivo)
            setupInitialCronograma()
        }
        saveUserData()
    }
    
//    MARK: - Geração de Cronograma
    func setupInitialCronograma() {
        guard var currentUsuario = usuario else { return }
        
//        Horas padrão por dia para um cronograma inicial (apenas demonstração)
        let horasPadrao: [DayOfWeek: Double] = [
            .monday: 3.0, .tuesday: 2.0, .wednesday: 3.0, .thursday: 2.0, .friday: 2.0, .saturday: 4.0, .sunday: 1.0
        ]
        
        let novoCronograma = Cronograma(dataCriacao: Date(), horasDisponiveisPorDia: horasPadrao, tarefas: TarefaEstudo.mockTarefas)
        currentUsuario.cronogramas.append(novoCronograma)
        self.usuario = currentUsuario
        self.cronogramaAtual = novoCronograma
        saveUserData()
    }
    
//    Função para gerar um cronograma mais dinâmico
    func gerarCronogramaPersonalizado(horasPorDia: [DayOfWeek: Double], tarefasPendentes: [TarefaEstudo]) {
        guard var currentUsuario = usuario else { return }
        
//        Criar um novo cronograma com as horas disponíveis e adicionar tarefas
        let novoCronograma = Cronograma(dataCriacao: Date(), horasDisponiveisPorDia: horasPorDia, tarefas: tarefasPendentes)
        currentUsuario.cronogramas.append(novoCronograma)
        self.usuario = currentUsuario
        self.cronogramaAtual = novoCronograma
        saveUserData()
        setupDailyTasks() // Atualiza as tarefas do dia após gerar um novo cronograma
        calculateWeeklyProgress()
    }
    
//    MARK: - Monitoramento de Progresso
    func setupDailyTasks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        tarefasDoDia = cronogramaAtual?.tarefas.filter { task in
            calendar.isDate(task.data, inSameDayAs: today)
        } ?? []
    }
    
    func marcarTarefaConcluida(_ tarefa: TarefaEstudo) {
        guard var currentCronograma = cronogramaAtual else { return }
        if let index = currentCronograma.tarefas.firstIndex(where: { $0.id == tarefa.id }) {
            currentCronograma.tarefas[index].concluida.toggle()
            
//            Atualiza as horas estudadas para o dia atual se a tarefa foi marcada como concluída
            if currentCronograma.tarefas[index].concluida {
                addHoursToDailyHistory(hours: tarefa.horasEstimadas)
            } else {
//                Se desmarcada, remove as horas
                removeHoursFromDailyHistory(hours: tarefa.horasEstimadas)
            }
            
            self.cronogramaAtual = currentCronograma
            if let userIndex = usuario?.cronogramas.firstIndex(where: { $0.id == currentCronograma.id }) {
                usuario?.cronogramas[userIndex] = currentCronograma
                saveUserData()
            }
            calculateWeeklyProgress()
            setupDailyTasks() // Atualiza a lista de tarefas do dia
        }
    }
    
//    Adiciona horas ao histórico diário do usuário
    private func addHoursToDailyHistory(hours: Double) {
        guard var currentUsuario = usuario else { return }
        let today = Calendar.current.startOfDay(for: Date())
        currentUsuario.historicoDiario[today, default: 0.0] += hours
        self.usuario = currentUsuario
        saveUserData()
    }
    
//    Remove horas do histórico diário do usuário (se uma tarefa for desmarcada)
    private func removeHoursFromDailyHistory(hours: Double) {
        guard var currentUsuario = usuario else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if let currentHours = currentUsuario.historicoDiario[today] {
            currentUsuario.historicoDiario[today] = max(0, currentHours - hours)
        }
        self.usuario = currentUsuario
        saveUserData()
    }
    
//    Calcula progresso semanal
    func calculateWeeklyProgress() {
        guard let cronograma = cronogramaAtual, let user = usuario else {
            progressoSemanal = 0.0
            horasTotaisPrevistasSemana = 0.0
            horasEstudadasSemana = 0.0
            return
        }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfweek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
//        Horas previstas na semana
        var totalHorasPrevistas: Double = 0.0
        for day in DayOfWeek.allCases {
            totalHorasPrevistas += cronograma.horasDisponiveisPorDia[day] ?? 0.0
        }
        self.horasTotaisPrevistasSemana = totalHorasPrevistas
        
//        Horas realmente estudas na semana
        var totalHorasEstudadas: Double = 0.0
        for (date, hours) in user.historicoDiario {
            if date >= startOfWeek && date < endOfweek {
                totalHorasEstudadas += hours
            }
        }
        self.horasEstudadasSemana = totalHorasEstudadas
        
        if totalHorasPrevistas > 0 {
            progressoSemanal = min(1.0, totalHorasEstudadas / totalHorasPrevistas)
        } else {
            progressoSemanal = 0.0
        }
    }
}
