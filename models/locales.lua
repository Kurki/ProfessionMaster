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
            ["ProfessionsViewTitle"] = "Profession Master - Overview",
            ["ProfessionsViewProfession"] = "Profession",
            ["ProfessionsViewAllProfessions"] = "All Professions",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "All Addons",
            ["ProfessionsViewSearch"] = "Search",
            ["ProfessionsViewItem"] = "Item",
            ["ProfessionsViewEnchantment"] = "Enchantment",
            ["ProfessionsViewPlayers"] = "Players",
            ["ProfessionsViewBucketList"] = "Shopping List",
            ["ProfessionsViewReagentsForBucketList"] = "Reagents for Shopping List",
            ["ProfessionsViewNotOnBucketList"] = "Other",
            ["ProfessionsViewFooter"] = "|cffDA8CFFLeft Click: |cffffffffShow details / Add to Shopping List.   |cffDA8CFFShift + Left Click: |cffffffffItem link into chat.   |cffDA8CFFCtrl + Shift + Left Click: |cffffffffSkill link into chat.",
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
            ['WhoOtherCanCraftResponse'] = "can craft that for you!"
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
            ["ProfessionsViewTitle"] = "Profession Master - Übersicht",
            ["ProfessionsViewProfession"] = "Beruf",
            ["ProfessionsViewAllProfessions"] = "Alle Berufe",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Alle Addons",
            ["ProfessionsViewSearch"] = "Suchen",
            ["ProfessionsViewItem"] = "Gegenstand",
            ["ProfessionsViewEnchantment"] = "Verzauberung",
            ["ProfessionsViewPlayers"] = "Spieler",
            ["ProfessionsViewBucketList"] = "Einkaufliste",
            ["ProfessionsViewReagentsForBucketList"] = "Materialien für Einkaufliste",
            ["ProfessionsViewNotOnBucketList"] = "Weitere",
            ["ProfessionsViewFooter"] = "|cffDA8CFFLinksklick: |cffffffffDetails anzeigen / Auf Einkaufliste setzen.   |cffDA8CFFShift + Linksklick: |cffffffffItem-Link in Chat.   |cffDA8CFFStrg + Shift + Linksklick: |cffffffffSkill-Link in Chat.",
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
            ['WhoOtherCanCraftResponse'] = "kann dir das herstellen!"
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
            ["ProfessionsViewTitle"] = "Profession Master - Обзор",
            ["ProfessionsViewProfession"] = "Профессия",
            ["ProfessionsViewAllProfessions"] = "Все профессии",
            ["ProfessionsViewAddon"] = "Аддон",
            ["ProfessionsViewAllAddons"] = "Все аддоны",
            ["ProfessionsViewSearch"] = "Поиск",
            ["ProfessionsViewItem"] = "Предмет",
            ["ProfessionsViewEnchantment"] = "Зачарование",
            ["ProfessionsViewPlayers"] = "Игроки",
            ["ProfessionsViewBucketList"] = "Список покупок",
            ["ProfessionsViewReagentsForBucketList"] = "Реагенты для списка покупок",
            ["ProfessionsViewNotOnBucketList"] = "Прочее",
            ["ProfessionsViewFooter"] = "|cffDA8CFFЛевый клик: |cffffffffПоказать детали / Добавить в список покупок.   |cffDA8CFFShift + Левый клик: |cffffffffСсылка на предмет в чат.   |cffDA8CFFCtrl + Shift + Левый клик: |cffffffffСсылка на навык в чат.",
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
            ["WhoOtherCanCraftResponse"] = "может это для тебя сделать!"
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
            ["ProfessionsViewTitle"] = "Profession Master - Vista general",
            ["ProfessionsViewProfession"] = "Profesión",
            ["ProfessionsViewAllProfessions"] = "Todas las profesiones",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Todos los addons",
            ["ProfessionsViewSearch"] = "Buscar",
            ["ProfessionsViewItem"] = "Objeto",
            ["ProfessionsViewEnchantment"] = "Encantamiento",
            ["ProfessionsViewPlayers"] = "Jugadores",
            ["ProfessionsViewBucketList"] = "Lista de compras",
            ["ProfessionsViewReagentsForBucketList"] = "Materiales para la lista de compras",
            ["ProfessionsViewNotOnBucketList"] = "Otros",
            ["ProfessionsViewFooter"] = "|cffDA8CFFClic izquierdo: |cffffffffMostrar detalles / Añadir a la lista de compras.   |cffDA8CFFShift + Clic izquierdo: |cffffffffEnlace del objeto en el chat.   |cffDA8CFFCtrl + Shift + Clic izquierdo: |cffffffffEnlace de habilidad en el chat.",
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
            ["WhoOtherCanCraftResponse"] = "puede fabricarte eso!"
        }
    };
end
