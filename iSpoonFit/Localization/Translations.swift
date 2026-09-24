import Foundation

/// Every user-facing string in the app, in European Portuguese and English.
/// The table is split across files by area purely to keep each one readable;
/// `table` merges them into the single dictionary `LocalizationManager` reads.
enum Translations {
    static let table: [String: [Lang: String]] = {
        var merged = core
        for part in [program, exercises, cues, account] {
            merged.merge(part) { current, _ in current }
        }
        return merged
    }()

    static let core: [String: [Lang: String]] = [
        // MARK: App and credits
        "app.name": [.pt: "iSpoonFit", .en: "iSpoonFit"],
        "app.tagline": [
            .pt: "Treino suave e progressivo, 20 minutos por dia",
            .en: "Gentle, progressive training, 20 minutes a day"
        ],
        "about.developedBy": [
            .pt: "Desenvolvido por",
            .en: "Developed by"
        ],
        "about.authorName": [.pt: "David Arsénio Martins", .en: "David Arsénio Martins"],
        "about.version": [.pt: "Versão", .en: "Version"],
        "about.website": [.pt: "Site", .en: "Website"],
        "about.github": [.pt: "GitHub", .en: "GitHub"],

        // MARK: Tabs
        "tab.today": [.pt: "Hoje", .en: "Today"],
        "tab.program": [.pt: "Programa", .en: "Program"],
        "tab.exercises": [.pt: "Exercícios", .en: "Exercises"],
        "tab.settings": [.pt: "Definições", .en: "Settings"],

        // MARK: Greetings
        "greeting.morning": [.pt: "Bom dia", .en: "Good morning"],
        "greeting.afternoon": [.pt: "Boa tarde", .en: "Good afternoon"],
        "greeting.evening": [.pt: "Boa noite", .en: "Good evening"],

        // MARK: Today
        "today.start": [.pt: "Começar treino", .en: "Start workout"],
        "today.repeat": [.pt: "Repetir treino", .en: "Repeat workout"],
        "today.restDay": [.pt: "Dia de descanso", .en: "Rest day"],
        "today.restTip": [
            .pt: "Uma caminhada leve e alguns minutos de respiração calma ajudam na recuperação.",
            .en: "A light walk and a few minutes of calm breathing help recovery."
        ],
        "today.restWalk": [.pt: "Caminhada de 10 a 20 minutos", .en: "A 10 to 20 minute walk"],
        "today.restBreathing": [.pt: "Respiração diafragmática", .en: "Diaphragmatic breathing"],
        "today.restStretch": [.pt: "Alongamentos suaves", .en: "Gentle stretching"],
        "today.nextWorkout": [.pt: "Próximo treino", .en: "Next workout"],
        "today.nextInDays": [.pt: "Daqui a %d dias", .en: "In %d days"],
        "today.nextTomorrow": [.pt: "Amanhã", .en: "Tomorrow"],
        "today.progress": [.pt: "O teu progresso", .en: "Your progress"],
        "today.daysDone": [.pt: "Dias concluídos", .en: "Days done"],
        "today.doneTitle": [.pt: "Treino de hoje feito", .en: "Today's workout is done"],
        "today.doneBody": [
            .pt: "Descansa e bebe água. O próximo treino fica à tua espera.",
            .en: "Rest and drink some water. Your next workout will be waiting for you."
        ],
        "today.startsSoon": [.pt: "Quase a começar", .en: "Almost time"],
        "today.startsOn": [.pt: "O programa começa %@.", .en: "The program starts %@."],
        "today.startNow": [.pt: "Começar já hoje", .en: "Start today instead"],
        "today.weeksDone": [.pt: "Semanas completas", .en: "Full weeks"],
        "today.programComplete": [.pt: "Programa concluído!", .en: "Program complete!"],
        "today.programCompleteBody": [
            .pt: "Fizeste os 28 treinos. Podes repetir qualquer dia sempre que quiseres.",
            .en: "You finished all 28 workouts. You can repeat any day whenever you like."
        ],
        "today.ofTotal": [.pt: "de %d", .en: "of %d"],

        // MARK: Low-energy mode
        "lowEnergy.title": [.pt: "Dia difícil", .en: "Low-energy day"],
        "lowEnergy.subtitle": [
            .pt: "Menos uma volta, mais descanso, versões mais fáceis",
            .en: "One fewer round, more rest, easier versions"
        ],

        // MARK: Focus areas and categories
        "focus.core": [.pt: "Core", .en: "Core"],
        "focus.glutes": [.pt: "Glúteos", .en: "Glutes"],
        "focus.thighs": [.pt: "Coxas", .en: "Thighs"],
        "category.all": [.pt: "Todos", .en: "All"],
        "category.warmup": [.pt: "Aquecimento", .en: "Warm-up"],
        "category.legsGlutes": [.pt: "Pernas e glúteos", .en: "Legs & glutes"],
        "category.core": [.pt: "Core", .en: "Core"],
        "category.stretch": [.pt: "Alongamentos", .en: "Stretching"],

        // MARK: Exercise detail sections
        "detail.muscles": [.pt: "Músculos trabalhados", .en: "Muscles worked"],
        "detail.steps": [.pt: "Como fazer", .en: "How to do it"],
        "detail.breathing": [.pt: "Respiração", .en: "Breathing"],
        "detail.mistake": [.pt: "Erro comum", .en: "Common mistake"],
        "detail.easier": [.pt: "Versão mais fácil", .en: "Easier version"],
        "detail.caution": [.pt: "Cuidados", .en: "Caution"],
        "exercises.searchPlaceholder": [.pt: "Procurar exercício", .en: "Search exercise"],
        "exercises.empty": [.pt: "Nenhum exercício encontrado.", .en: "No exercises found."],

        // MARK: Settings
        "settings.language": [.pt: "Idioma", .en: "Language"],
        "settings.appearance": [.pt: "Aparência", .en: "Appearance"],
        "settings.session": [.pt: "Durante o treino", .en: "During the workout"],
        "settings.program": [.pt: "Programa", .en: "Program"],
        "settings.sound": [.pt: "Sons", .en: "Sounds"],
        "settings.voice": [.pt: "Voz de contagem", .en: "Voice countdown"],
        "settings.haptics": [.pt: "Vibração", .en: "Haptics"],
        "settings.reminders": [.pt: "Lembretes", .en: "Reminders"],
        "settings.reminderTime": [.pt: "Hora do lembrete", .en: "Reminder time"],
        "settings.remindersDenied": [
            .pt: "As notificações estão desligadas para o iSpoonFit. Ativa-as nas Definições do iPhone.",
            .en: "Notifications are off for iSpoonFit. Turn them on in the iPhone Settings app."
        ],
        "settings.reminderDays": [
            .pt: "Por defeito, nos dias de treino, de segunda a quinta.",
            .en: "By default on training days, Monday to Thursday."
        ],
        "settings.startDate": [.pt: "Data de início", .en: "Start date"],
        "settings.restart": [.pt: "Reiniciar programa", .en: "Restart program"],
        "settings.restartConfirm": [
            .pt: "Isto apaga todos os treinos concluídos e volta ao Dia 1. Não é possível anular.",
            .en: "This deletes every completed workout and goes back to Day 1. It cannot be undone."
        ],
        "settings.safety": [.pt: "Informação de segurança", .en: "Safety information"],
        "settings.history": [.pt: "Histórico", .en: "History"],
        "settings.about": [.pt: "Sobre", .en: "About"],
        "theme.light": [.pt: "Claro", .en: "Light"],
        "theme.dark": [.pt: "Escuro", .en: "Dark"],
        "theme.system": [.pt: "Sistema", .en: "System"],

        // MARK: Generic actions
        "action.cancel": [.pt: "Cancelar", .en: "Cancel"],
        "action.close": [.pt: "Fechar", .en: "Close"],
        "action.done": [.pt: "Concluir", .en: "Done"],
        "action.back": [.pt: "Voltar", .en: "Back"],
        "action.next": [.pt: "Seguinte", .en: "Next"],
        "action.understood": [.pt: "Percebi", .en: "Got it"],
        "action.delete": [.pt: "Apagar", .en: "Delete"],

        // MARK: Onboarding
        "onboarding.welcomeTitle": [.pt: "Bem-vinda ao iSpoonFit", .en: "Welcome to iSpoonFit"],
        "onboarding.welcomeBody": [
            .pt: "28 treinos de 20 minutos, de segunda a quinta, em casa e sem saltos. Cada semana avança um pouco, ao teu ritmo.",
            .en: "28 workouts of 20 minutes, Monday to Thursday, at home and with no jumping. Each week steps up a little, at your own pace."
        ],
        "onboarding.safetyTitle": [.pt: "Primeiro, a tua segurança", .en: "Your safety first"],
        "onboarding.clearance": [
            .pt: "Tenho autorização médica para fazer exercício",
            .en: "I have medical clearance to exercise"
        ],
        "onboarding.materialTitle": [.pt: "O que vais precisar", .en: "What you'll need"],
        "onboarding.materialBody": [
            .pt: "Nada de ginásio. Um canto tranquilo e estas quatro coisas chegam.",
            .en: "No gym needed. A quiet corner and these four things are enough."
        ],
        "onboarding.startTitle": [.pt: "Quando começamos?", .en: "When do we start?"],
        "onboarding.startBody": [
            .pt: "O programa corre de segunda a quinta. Escolhe a segunda-feira em que queres começar.",
            .en: "The program runs Monday to Thursday. Pick the Monday you want to start on."
        ],
        "onboarding.reminderToggle": [.pt: "Lembrar-me de treinar", .en: "Remind me to train"],
        "onboarding.workouts": [.pt: "treinos", .en: "workouts"],
        "onboarding.start": [.pt: "Começar", .en: "Get started"],

        // MARK: Materials
        "material.mat": [.pt: "Tapete", .en: "Mat"],
        "material.chair": [.pt: "Cadeira", .en: "Chair"],
        "material.bottles": [.pt: "2 garrafas de água (opcional)", .en: "2 water bottles (optional)"],
        "material.towel": [.pt: "Toalha", .en: "Towel"],

        // MARK: Safety card
        "safety.title": [.pt: "Antes de começares", .en: "Before you start"],
        "safety.point1": [
            .pt: "Este programa não substitui aconselhamento médico. Fala com o teu médico antes de começar, sobretudo após o parto ou uma cesariana.",
            .en: "This program does not replace medical advice. Talk to your doctor before starting, especially after giving birth or a C-section."
        ],
        "safety.point2": [
            .pt: "Depois de uma cesariana, espera pela autorização médica e começa sempre pela Semana 1.",
            .en: "After a C-section, wait for medical clearance and always start from Week 1."
        ],
        "safety.point3": [
            .pt: "Expira durante o esforço e nunca prendas a respiração.",
            .en: "Breathe out on the effort and never hold your breath."
        ],
        "safety.point4": [
            .pt: "Para imediatamente se sentires dor na cicatriz, hemorragia, peso ou pressão pélvica, tonturas, dor no peito ou dor articular aguda.",
            .en: "Stop immediately if you feel pain at the scar, bleeding, pelvic heaviness or pressure, dizziness, chest pain or sharp joint pain."
        ],
        "safety.point5": [
            .pt: "Se o abdómen fizer uma crista ou volume ao centro durante um exercício, reduz a intensidade e fala com um fisioterapeuta.",
            .en: "If your belly forms a ridge or bulge along the midline during an exercise, reduce the intensity and speak to a physiotherapist."
        ],
        "safety.point6": [
            .pt: "Em fase de surto ou de maior fadiga, descansa ou usa o modo Dia difícil.",
            .en: "During a flare or on high-fatigue days, rest or use Low-energy day mode."
        ]
    ]
}
