--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create model
local LocalesModel = _G.professionMaster:CreateModel("locales");

-- Create model.
function LocalesModel:Create()
    return {
        -- define en locale
        ["en"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " by Kurki. Use |cffDA8CFF/pm help|r for more informations.",
            ["VersionOutdated"] = "Your version is outdated. The latest version can be downloaded from https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "I'm now sharing my professions with Profession Master. Type “!who [item]” and I might be able to tell you who can craft it for you.",
            ["LanguageNotSupported"] = "Unfortunately, the language of your client is not supported by ProfessionMaster.",
            ["You"] = "You",

            -- commands
            ["CommandsTitle"] = "Possible commands:",
            ["CommandsOverview"] = "/pm - Show/Hide professions overview",
            ["CommandsMinimap"] = "/pm minimap - Show minimap icon",
            ["CommandsReagents"] = "/pm reagents - Show/Hide missing Reagents",
            ["CommandsPurge"] = "/pm purge [all | own | <player name>] - Delete all data, the data of yourself or of a specific player",
            ["CommandsPurgeRow1"] = "Possible purge commands:",
            ["CommandsPurgeRow2"] = "/pm purge all - Delete all data",
            ["CommandsPurgeRow3"] = "/pm purge own - Delete data of yourself",
            ["CommandsPurgeRow4"] = "/pm purge <player name> - Delete data of a specific player",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Welcome",
            ["WelcomeDescription"] = self.addon.name .. " shows you your profession and the professions of all your guild members who also use " .. self.addon.name .. " in a single overview.\n\n" .. 
                "Use the button on your minimap or the chat command /pm to show or hide the corresponding windows.\n\n" ..
                "|cffd4af37Open your profession windows now to share your professions.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Left Click:|cffffffff Show overview|r",
            ["MinimapButtonRightClick"] = "|cff999999Right Click:|cffffffff Show/Hide missing Reagents|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Right Click:|cffffffff Hide minimap button|r",

            -- provession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Overview - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Profession",
            ["ProfessionsViewAllProfessions"] = "All Professions",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "All Addons",
            ["ProfessionsViewSearch"] = "Search",
            ["ProfessionsViewItem"] = "Item",
            ["ProfessionsViewEnchantment"] = "Enchantment",
            ["ProfessionsViewPlayers"] = "Players",
            ["ProfessionsViewBucketList"] = "Shopping List",
            ["ProfessionsViewMissingReagents"] = "Missing Reagents",
            ["ProfessionsViewCraftSelf"] = "Craft yourself",
            ["ProfessionsViewRemoveFromWatchList"] = "Remove from watchlist",
            ["ProfessionsViewRemoveFromBucketList"] = "Remove from shopping list",
            ["ProfessionsViewClearBucketList"] = "Clear shopping list",
            ["ProfessionsViewNotOnBucketList"] = "Other",
            ["ProfessionsViewFooter"] = "|cffDA8CFFLeft Click: |cffffffffShow details.   |cffDA8CFFShift + Left Click: |cffffffffItem link into chat.   |cffDA8CFFCtrl + Shift + Left Click: |cffffffffSkill link into chat.",
            ["ProfessionsViewAnnounce"] = "Promote in Guild Chat",

            -- skill view
            ["SkillViewPlayers"] = "Players",
            ["SkillViewOnBucketList"] = "On Shopping List",
            ["SkillViewOk"] = "OK",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Missing Reagents",

            -- purge
            ["AllDataPurged"] = "All data was deleted",
            ["CharacterPurged"] = "Data of %s was deleted",

            -- who
            ["WhoCraftResponse"] = "I can craft that for you!",
            ["WhoCannotCraftResponse"] = "Unfortunately, I don't know anyone who can craft that.",
            ['WhoOtherCanCraftResponse'] = "can craft that for you!",

            -- specializations
            ["Specialization"] = "Specialization",
            ["Spec28675"] = "Potion Master",
            ["Spec28677"] = "Elixir Master",
            ["Spec28672"] = "Transmutation Master",
            ["Spec9788"] = "Armorsmith",
            ["Spec9787"] = "Weaponsmith",
            ["Spec17039"] = "Master Swordsmith",
            ["Spec17040"] = "Master Hammersmith",
            ["Spec17041"] = "Master Axesmith",
            ["Spec10656"] = "Dragonscale Leatherworking",
            ["Spec10658"] = "Elemental Leatherworking",
            ["Spec10660"] = "Tribal Leatherworking",
            ["Spec26797"] = "Spellfire Tailoring",
            ["Spec26801"] = "Shadoweave Tailoring",
            ["Spec26798"] = "Mooncloth Tailoring",
            ["Spec20219"] = "Gnomish Engineering",
            ["Spec20222"] = "Goblin Engineering"
        },
        -- define de locale
        ["de"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " von Kurki. Benutze |cffDA8CFF/pm help|r für weitere Informationen.",
            ["VersionOutdated"] = "Deine Version ist veraltet. Die neueste Version kann unter https://www.curseforge.com/wow/addons/profession-master heruntergeladen werden.",
            ["LanguageNotSupported"] = "Leider wird die Sprache deines Clients nicht von ProfessionMaster unterstützt.",
            ["GuildAnnouncement"] = "Ich teile jetzt meine Berufe mit Profession Master. Schreibe “!who [item]” und ich kann dir vielleicht sagen, wer das für dich herstellen kann.",
            ["You"] = "Du",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Willkommen",
            ["WelcomeDescription"] = self.addon.name .. " zeigt dir deine und die Berufe all deiner Gildenmitglieder, die auch " .. self.addon.name .. " nutzen, in einer einzigen Übersicht an.\n\n" ..
                "Benutze die Schaltfläche an deiner Minimap oder den Chat-Befehl /pm um die entsprechenden Fenster ein- oder auszublenden.\n\n" .. 
                "|cffd4af37Öffne jetzt deine Berufsfenster, um deine Berufe zu teilen.",

            -- commands
            ["CommandsTitle"] = "Mögliche Befehle:",
            ["CommandsOverview"] = "/pm - Berufsübersicht ein-/ausblenden",
            ["CommandsMinimap"] = "/pm minimap - Minimap icon anzeigen",
            ["CommandsReagents"] = "/pm reagents - Fehlende Materialien ein-/ausblenden",
            ["CommandsPurge"] = "/pm purge [all | own | <Spielername>] - Lösche alle Daten, Daten von dir oder von einem spezifischen Spieler",
            ["CommandsPurgeRow1"] = "Mögliche Lösch-Befehle:",
            ["CommandsPurgeRow2"] = "/pm purge all - Lösche alle Daten",
            ["CommandsPurgeRow3"] = "/pm purge own - Lösche Daten von dir",
            ["CommandsPurgeRow4"] = "/pm purge <Spielername> - Lösche Daten von einem spezifischen Spieler",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Linksklick:|cffffffff Übersicht anzeigen|r",
            ["MinimapButtonRightClick"] = "|cff999999Rechtsklick:|cffffffff Fehlende Materialien ein-/ausblenden|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Rechtsklick:|cffffffff Minimap Schaltfläche ausblenden|r",

            -- provession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Übersicht - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Beruf",
            ["ProfessionsViewAllProfessions"] = "Alle Berufe",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Alle Addons",
            ["ProfessionsViewSearch"] = "Suchen",
            ["ProfessionsViewItem"] = "Gegenstand",
            ["ProfessionsViewEnchantment"] = "Verzauberung",
            ["ProfessionsViewPlayers"] = "Spieler",
            ["ProfessionsViewBucketList"] = "Einkaufliste",
            ["ProfessionsViewMissingReagents"] = "Fehlende Reagenzien",
            ["ProfessionsViewCraftSelf"] = "Selbst herstellen",
            ["ProfessionsViewRemoveFromWatchList"] = "Nicht mehr selbst herstellen",
            ["ProfessionsViewRemoveFromBucketList"] = "Von Einkaufliste entfernen",
            ["ProfessionsViewClearBucketList"] = "Einkaufsliste leeren",
            ["ProfessionsViewNotOnBucketList"] = "Weitere",
            ["ProfessionsViewFooter"] = "|cffDA8CFFLinksklick: |cffffffffDetails anzeigen.   |cffDA8CFFShift + Linksklick: |cffffffffItem-Link in Chat.   |cffDA8CFFStrg + Shift + Linksklick: |cffffffffSkill-Link in Chat.",
            ["ProfessionsViewAnnounce"] = "Im Gildenchat ankündigen",

            -- skill view
            ["SkillViewPlayers"] = "Spieler",
            ["SkillViewOnBucketList"] = "Auf Einkaufliste",
            ["SkillViewOk"] = "OK",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Fehlende Materialien",

            -- purge
            ["AllDataPurged"] = "Alle Daten wurden gelöscht",
            ["CharacterPurged"] = "Daten von %s wurden gelöscht",

            -- who
            ["WhoCraftResponse"] = "Ich kann dir das herstellen!",
            ["WhoCannotCraftResponse"] = "Ich kenne leider niemanden der das herstellen kann.",
            ['WhoOtherCanCraftResponse'] = "kann dir das herstellen!",

            -- specializations
            ["Specialization"] = "Spezialisierung",
            ["Spec28675"] = "Trankmeister",
            ["Spec28677"] = "Elixiermeister",
            ["Spec28672"] = "Transmutationsmeister",
            ["Spec9788"] = "Rüstungsschmied",
            ["Spec9787"] = "Waffenschmied",
            ["Spec17039"] = "Schwertschmiedemeister",
            ["Spec17040"] = "Hammerschmiedemeister",
            ["Spec17041"] = "Axtschmiedemeister",
            ["Spec10656"] = "Drachenschuppenlederverarbeitung",
            ["Spec10658"] = "Elementarlederverarbeitung",
            ["Spec10660"] = "Stammeslederverarbeitung",
            ["Spec26797"] = "Zauberfeuerschneiderei",
            ["Spec26801"] = "Schattenweberschneiderei",
            ["Spec26798"] = "Urmondstoffschneiderei",
            ["Spec20219"] = "Gnomeningenieur",
            ["Spec20222"] = "Gobliningenieur"
        },
        -- define ru locale
        ["ru"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " от Kurki. Используйте |cffDA8CFF/pm help|r для дополнительной информации.",
            ["VersionOutdated"] = "Ваша версия устарела. Последнюю версию можно скачать на https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "Теперь я делюсь своими профессиями с Profession Master. Напишите “!who [item]”, и я, возможно, смогу сказать, кто может это сделать для вас.",
            ["LanguageNotSupported"] = "К сожалению, язык вашего клиента не поддерживается ProfessionMaster.",
            ["You"] = "Вы",

            -- commands
            ["CommandsTitle"] = "Доступные команды:",
            ["CommandsOverview"] = "/pm - Показать/скрыть обзор профессий",
            ["CommandsMinimap"] = "/pm minimap - Показать значок на миникарте",
            ["CommandsReagents"] = "/pm reagents - Показать/скрыть недостающие реагенты",
            ["CommandsPurge"] = "/pm purge [all | own | <имя игрока>] - Удалить все данные, ваши данные или данные определенного игрока",
            ["CommandsPurgeRow1"] = "Доступные команды удаления:",
            ["CommandsPurgeRow2"] = "/pm purge all - Удалить все данные",
            ["CommandsPurgeRow3"] = "/pm purge own - Удалить ваши данные",
            ["CommandsPurgeRow4"] = "/pm purge <имя игрока> - Удалить данные определенного игрока",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Добро пожаловать",
            ["WelcomeDescription"] = self.addon.name .. " показывает ваши профессии и профессии всех членов вашей гильдии, которые также используют " .. self.addon.name .. ", в едином обзоре.\n\n" .. 
                "Используйте кнопку на миникарте или команду чата /pm, чтобы показать или скрыть соответствующие окна.\n\n" ..
                "|cffd4af37Откройте окна ваших профессий сейчас, чтобы поделиться ими.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Левый клик:|cffffffff Показать обзор|r",
            ["MinimapButtonRightClick"] = "|cff999999Правый клик:|cffffffff Показать/скрыть недостающие реагенты|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Правый клик:|cffffffff Скрыть кнопку на миникарте|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Обзор - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Профессия",
            ["ProfessionsViewAllProfessions"] = "Все профессии",
            ["ProfessionsViewAddon"] = "Аддон",
            ["ProfessionsViewAllAddons"] = "Все аддоны",
            ["ProfessionsViewSearch"] = "Поиск",
            ["ProfessionsViewItem"] = "Предмет",
            ["ProfessionsViewEnchantment"] = "Зачарование",
            ["ProfessionsViewPlayers"] = "Игроки",
            ["ProfessionsViewBucketList"] = "Список покупок",
            ["ProfessionsViewMissingReagents"] = "Недостающие реагенты",
            ["ProfessionsViewCraftSelf"] = "Сделать самому",
            ["ProfessionsViewRemoveFromWatchList"] = "Убрать из списка отслеживания",
            ["ProfessionsViewRemoveFromBucketList"] = "Удалить из списка покупок",
            ["ProfessionsViewClearBucketList"] = "Очистить список покупок",
            ["ProfessionsViewNotOnBucketList"] = "Прочее",
            ["ProfessionsViewFooter"] = "|cffDA8CFFЛевый клик: |cffffffffПоказать детали.   |cffDA8CFFShift + Левый клик: |cffffffffСсылка на предмет в чат.   |cffDA8CFFCtrl + Shift + Левый клик: |cffffffffСсылка на навык в чат.",
            ["ProfessionsViewAnnounce"] = "Объявить в чате гильдии",

            -- skill view
            ["SkillViewPlayers"] = "Игроки",
            ["SkillViewOnBucketList"] = "В списке покупок",
            ["SkillViewOk"] = "ОК",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Недостающие реагенты",

            -- purge
            ["AllDataPurged"] = "Все данные были удалены",
            ["CharacterPurged"] = "Данные %s были удалены",

            -- who
            ["WhoCraftResponse"] = "Я могу это для тебя сделать!",
            ["WhoCannotCraftResponse"] = "К сожалению, я не знаю никого, кто может это сделать.",
            ["WhoOtherCanCraftResponse"] = "может это для тебя сделать!",

            -- specializations
            ["Specialization"] = "Специализация",
            ["Spec28675"] = "Мастер зелий",
            ["Spec28677"] = "Мастер эликсиров",
            ["Spec28672"] = "Мастер трансмутации",
            ["Spec9788"] = "Бронник",
            ["Spec9787"] = "Оружейник",
            ["Spec17039"] = "Мастер мечей",
            ["Spec17040"] = "Мастер молотов",
            ["Spec17041"] = "Мастер топоров",
            ["Spec10656"] = "Драконья кожа",
            ["Spec10658"] = "Стихии",
            ["Spec10660"] = "Племенное",
            ["Spec26797"] = "Чародейский огонь",
            ["Spec26801"] = "Тень",
            ["Spec26798"] = "Лунная ткань",
            ["Spec20219"] = "Гномская инженерия",
            ["Spec20222"] = "Гоблинская инженерия"
        },
        -- define es locale
        ["es"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " por Kurki. Usa |cffDA8CFF/pm help|r para más información.",
            ["VersionOutdated"] = "Tu versión está desactualizada. La última versión se puede descargar en https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "Ahora comparto mis profesiones con Profession Master. Escribe “!who [item]” y quizás pueda decirte quién puede fabricarlo para ti.",
            ["LanguageNotSupported"] = "Lamentablemente, el idioma de tu cliente no es compatible con ProfessionMaster.",
            ["You"] = "Tú",

            -- commands
            ["CommandsTitle"] = "Comandos disponibles:",
            ["CommandsOverview"] = "/pm - Mostrar/Ocultar vista general de profesiones",
            ["CommandsMinimap"] = "/pm minimap - Mostrar icono del minimapa",
            ["CommandsReagents"] = "/pm reagents - Mostrar/Ocultar materiales faltantes",
            ["CommandsPurge"] = "/pm purge [all | own | <nombre del jugador>] - Eliminar todos los datos, tus datos o los de un jugador específico",
            ["CommandsPurgeRow1"] = "Comandos de eliminación disponibles:",
            ["CommandsPurgeRow2"] = "/pm purge all - Eliminar todos los datos",
            ["CommandsPurgeRow3"] = "/pm purge own - Eliminar tus datos",
            ["CommandsPurgeRow4"] = "/pm purge <nombre del jugador> - Eliminar datos de un jugador específico",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Bienvenido",
            ["WelcomeDescription"] = self.addon.name .. " te muestra tus profesiones y las de todos los miembros de tu gremio que también usan " .. self.addon.name .. " en una sola vista general.\n\n" ..
                "Usa el botón en tu minimapa o el comando de chat /pm para mostrar u ocultar las ventanas correspondientes.\n\n" ..
                "|cffd4af37Abre ahora tus ventanas de profesiones para compartir tus profesiones.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Clic izquierdo:|cffffffff Mostrar vista general|r",
            ["MinimapButtonRightClick"] = "|cff999999Clic derecho:|cffffffff Mostrar/Ocultar materiales faltantes|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Clic derecho:|cffffffff Ocultar botón del minimapa|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Vista general - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Profesión",
            ["ProfessionsViewAllProfessions"] = "Todas las profesiones",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Todos los addons",
            ["ProfessionsViewSearch"] = "Buscar",
            ["ProfessionsViewItem"] = "Objeto",
            ["ProfessionsViewEnchantment"] = "Encantamiento",
            ["ProfessionsViewPlayers"] = "Jugadores",
            ["ProfessionsViewBucketList"] = "Lista de compras",
            ["ProfessionsViewMissingReagents"] = "Materiales faltantes",
            ["ProfessionsViewCraftSelf"] = "Fabricarlo tú mismo",
            ["ProfessionsViewRemoveFromWatchList"] = "Quitar de la lista de seguimiento",
            ["ProfessionsViewRemoveFromBucketList"] = "Quitar de la lista de compras",
            ["ProfessionsViewClearBucketList"] = "Vaciar lista de compras",
            ["ProfessionsViewNotOnBucketList"] = "Otros",
            ["ProfessionsViewFooter"] = "|cffDA8CFFClic izquierdo: |cffffffffMostrar detalles.   |cffDA8CFFShift + Clic izquierdo: |cffffffffEnlace del objeto en el chat.   |cffDA8CFFCtrl + Shift + Clic izquierdo: |cffffffffEnlace de habilidad en el chat.",
            ["ProfessionsViewAnnounce"] = "Anunciar en el chat del gremio",

            -- skill view
            ["SkillViewPlayers"] = "Jugadores",
            ["SkillViewOnBucketList"] = "En la lista de compras",
            ["SkillViewOk"] = "OK",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Materiales faltantes",

            -- purge
            ["AllDataPurged"] = "Todos los datos fueron eliminados",
            ["CharacterPurged"] = "Los datos de %s fueron eliminados",

            -- who
            ["WhoCraftResponse"] = "¡Puedo fabricarte eso!",
            ["WhoCannotCraftResponse"] = "Lamentablemente, no conozco a nadie que pueda fabricar eso.",
            ["WhoOtherCanCraftResponse"] = "puede fabricarte eso!",

            -- specializations
            ["Specialization"] = "Especialización",
            ["Spec28675"] = "Maestro en pociones",
            ["Spec28677"] = "Maestro en elixires",
            ["Spec28672"] = "Maestro en transmutación",
            ["Spec9788"] = "Forjador de armaduras",
            ["Spec9787"] = "Forjador de armas",
            ["Spec17039"] = "Maestro espadero",
            ["Spec17040"] = "Maestro martillero",
            ["Spec17041"] = "Maestro hachas",
            ["Spec10656"] = "Peletería de escamas de dragón",
            ["Spec10658"] = "Peletería elemental",
            ["Spec10660"] = "Peletería tribal",
            ["Spec26797"] = "Sastrería de fuego mágico",
            ["Spec26801"] = "Sastrería de tejido de sombras",
            ["Spec26798"] = "Sastrería de tela lunar",
            ["Spec20219"] = "Ingeniería gnómica",
            ["Spec20222"] = "Ingeniería goblin"
        }
    };
end
