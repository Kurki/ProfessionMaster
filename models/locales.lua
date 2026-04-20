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
            ["CommandsLogs"] = "/pm logs - Show log entries",
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
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Left Click:|cffffffff Open settings|r",
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
            ["SkillViewAddToBucketList"] = "Add 1 to shopping list",
            ["SkillViewRemoveOneFromBucketList"] = "Remove 1 from shopping list",
            ["SkillViewRemoveFromBucketList"] = "Remove item from shopping list",
            ["SkillViewRecipe"] = "Recipe",
            ["SkillViewTaughtBy"] = "Taught by:",
            ["SkillViewTrainer"] = "Trainer",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Missing Reagents",

            -- help view
            ["HelpViewTitle"] = "Help",
            ["HelpTooltip"] = "Show Help",
            ["CloseTooltip"] = "Close",

            -- purge
            ["AllDataPurged"] = "All data was deleted",
            ["CharacterPurged"] = "Data of %s was deleted",
            ["PurgeViewTitle"] = "Purge Players",
            ["PurgeViewDescription"] = "Select the players to remove:",
            ["PurgeButtonText"] = "Purge selected (%d)",
            ["PurgeNoStalePlayers"] = "No players found that are no longer in the guild.",
            ["PurgeHeaderNotInGuild"] = "Players no longer in the guild:",
            ["PurgeHeaderOtherPlayers"] = "Other players:",
            ["PurgeNoPlayersFound"] = "No players found.",
            ["PurgeDone"] = "%d player(s) purged.",

            -- who
            ["WhoCraftResponse"] = "I can craft that for you!",
            ["WhoCannotCraftResponse"] = "Unfortunately, I don't know anyone who can craft that.",
            ['WhoOtherCanCraftResponse'] = "can craft that for you!",

            -- specializations
            ["Specialization"] = "Specialization",
            ["AllSpecializations"] = "All Specializations",
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
            ["Spec20222"] = "Goblin Engineering",

            -- settings
            ["SettingsRespondToWho"] = "Respond to !who",
            ["SettingsSendNonGuildCharacters"] = "Send professions of characters outside the guild",
            ["SettingsPurgeAll"] = "Delete all data",
            ["SkillCacheUpdating"] = "Data is being updated...",
            ["SkillCacheUpdated"] = "%d skills have been updated."
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
            ["CommandsLogs"] = "/pm logs - Protokolleinträge anzeigen",
            ["CommandsPurgeRow1"] = "Mögliche Lösch-Befehle:",
            ["CommandsPurgeRow2"] = "/pm purge all - Lösche alle Daten",
            ["CommandsPurgeRow3"] = "/pm purge own - Lösche Daten von dir",
            ["CommandsPurgeRow4"] = "/pm purge <Spielername> - Lösche Daten von einem spezifischen Spieler",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Linksklick:|cffffffff Übersicht anzeigen|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Linksklick:|cffffffff Einstellungen öffnen|r",
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
            ["SkillViewAddToBucketList"] = "Menge 1 zu Einkaufsliste hinzufügen",
            ["SkillViewRemoveOneFromBucketList"] = "Menge 1 von Einkaufsliste entfernen",
            ["SkillViewRemoveFromBucketList"] = "Gegenstand von Einkaufsliste entfernen",
            ["SkillViewRecipe"] = "Rezept",
            ["SkillViewTaughtBy"] = "Gelehrt durch:",
            ["SkillViewTrainer"] = "Lehrer",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Fehlende Materialien",

            -- help view
            ["HelpViewTitle"] = "Hilfe",
            ["HelpTooltip"] = "Hilfe anzeigen",
            ["CloseTooltip"] = "Schließen",

            -- purge
            ["AllDataPurged"] = "Alle Daten wurden gelöscht",
            ["CharacterPurged"] = "Daten von %s wurden gelöscht",
            ["PurgeViewTitle"] = "Spieler bereinigen",
            ["PurgeViewDescription"] = "Wähle die Spieler die entfernt werden sollen:",
            ["PurgeButtonText"] = "Ausgewählte (%d) löschen",
            ["PurgeNoStalePlayers"] = "Keine Spieler gefunden, die nicht mehr in der Gilde sind.",
            ["PurgeHeaderNotInGuild"] = "Spieler die nicht mehr in der Gilde sind:",
            ["PurgeHeaderOtherPlayers"] = "Andere Spieler:",
            ["PurgeNoPlayersFound"] = "Keine Spieler gefunden.",
            ["PurgeDone"] = "%d Spieler bereinigt.",

            -- who
            ["WhoCraftResponse"] = "Ich kann dir das herstellen!",
            ["WhoCannotCraftResponse"] = "Ich kenne leider niemanden der das herstellen kann.",
            ['WhoOtherCanCraftResponse'] = "kann dir das herstellen!",

            -- specializations
            ["Specialization"] = "Spezialisierung",
            ["AllSpecializations"] = "Alle Spezialisierungen",
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
            ["Spec20222"] = "Gobliningenieur",

            -- settings
            ["SettingsRespondToWho"] = "Auf !who reagieren",
            ["SettingsSendNonGuildCharacters"] = "Berufe von Charakteren au\195\159erhalb der Gilde senden",
            ["SettingsPurgeAll"] = "Alle Daten löschen",
            ["SkillCacheUpdating"] = "Daten werden aktualisiert...",
            ["SkillCacheUpdated"] = "%d Daten wurden aktualisiert."
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
            ["CommandsLogs"] = "/pm logs - Показать записи журнала",
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
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Левый клик:|cffffffff Открыть настройки|r",
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
            ["SkillViewAddToBucketList"] = "Добавить 1 в список покупок",
            ["SkillViewRemoveOneFromBucketList"] = "Убрать 1 из списка покупок",
            ["SkillViewRemoveFromBucketList"] = "Удалить предмет из списка покупок",
            ["SkillViewRecipe"] = "Рецепт",
            ["SkillViewTaughtBy"] = "Изучается через:",
            ["SkillViewTrainer"] = "Учитель",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Недостающие реагенты",

            -- help view
            ["HelpViewTitle"] = "Помощь",
            ["HelpTooltip"] = "Показать помощь",
            ["CloseTooltip"] = "Закрыть",

            -- purge
            ["AllDataPurged"] = "Все данные были удалены",
            ["CharacterPurged"] = "Данные %s были удалены",
            ["PurgeViewTitle"] = "Удалить игроков",
            ["PurgeViewDescription"] = "Выберите игроков для удаления:",
            ["PurgeButtonText"] = "Удалить выбранных (%d)",
            ["PurgeNoStalePlayers"] = "Не найдено игроков, которых больше нет в гильдии.",
            ["PurgeHeaderNotInGuild"] = "Игроки, которых больше нет в гильдии:",
            ["PurgeHeaderOtherPlayers"] = "Другие игроки:",
            ["PurgeNoPlayersFound"] = "Игроки не найдены.",
            ["PurgeDone"] = "%d игрок(ов) удалено.",

            -- who
            ["WhoCraftResponse"] = "Я могу это для тебя сделать!",
            ["WhoCannotCraftResponse"] = "К сожалению, я не знаю никого, кто может это сделать.",
            ["WhoOtherCanCraftResponse"] = "может это для тебя сделать!",

            -- specializations
            ["Specialization"] = "Специализация",
            ["AllSpecializations"] = "Все специализации",
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
            ["Spec20222"] = "Гоблинская инженерия",

            -- settings
            ["SettingsRespondToWho"] = "Отвечать на !who",
            ["SettingsSendNonGuildCharacters"] = "Отправлять профессии персонажей вне гильдии",
            ["SettingsPurgeAll"] = "Удалить все данные",
            ["SkillCacheUpdating"] = "Данные обновляются...",
            ["SkillCacheUpdated"] = "Обновлено навыков: %d."
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
            ["CommandsLogs"] = "/pm logs - Mostrar entradas del registro",
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
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Clic izquierdo:|cffffffff Abrir ajustes|r",
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
            ["SkillViewAddToBucketList"] = "Añadir 1 a la lista de compras",
            ["SkillViewRemoveOneFromBucketList"] = "Quitar 1 de la lista de compras",
            ["SkillViewRemoveFromBucketList"] = "Quitar objeto de la lista de compras",
            ["SkillViewRecipe"] = "Receta",
            ["SkillViewTaughtBy"] = "Enseñado por:",
            ["SkillViewTrainer"] = "Instructor",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Materiales faltantes",

            -- help view
            ["HelpViewTitle"] = "Ayuda",
            ["HelpTooltip"] = "Mostrar ayuda",
            ["CloseTooltip"] = "Cerrar",

            -- purge
            ["AllDataPurged"] = "Todos los datos fueron eliminados",
            ["CharacterPurged"] = "Los datos de %s fueron eliminados",
            ["PurgeViewTitle"] = "Purgar jugadores",
            ["PurgeViewDescription"] = "Selecciona los jugadores a eliminar:",
            ["PurgeButtonText"] = "Purgar seleccionados (%d)",
            ["PurgeNoStalePlayers"] = "No se encontraron jugadores que ya no est\195\169n en la hermandad.",
            ["PurgeHeaderNotInGuild"] = "Jugadores que ya no están en la hermandad:",
            ["PurgeHeaderOtherPlayers"] = "Otros jugadores:",
            ["PurgeNoPlayersFound"] = "No se encontraron jugadores.",
            ["PurgeDone"] = "%d jugador(es) purgado(s).",

            -- who
            ["WhoCraftResponse"] = "¡Puedo fabricarte eso!",
            ["WhoCannotCraftResponse"] = "Lamentablemente, no conozco a nadie que pueda fabricar eso.",
            ["WhoOtherCanCraftResponse"] = "puede fabricarte eso!",

            -- specializations
            ["Specialization"] = "Especialización",
            ["AllSpecializations"] = "Todas las especializaciones",
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
            ["Spec20222"] = "Ingeniería goblin",

            -- settings
            ["SettingsRespondToWho"] = "Responder a !who",
            ["SettingsSendNonGuildCharacters"] = "Enviar profesiones de personajes fuera del gremio",
            ["SettingsPurgeAll"] = "Eliminar todos los datos",
            ["SkillCacheUpdating"] = "Actualizando datos...",
            ["SkillCacheUpdated"] = "%d datos han sido actualizados."
        },
        -- define fr locale
        ["fr"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " par Kurki. Utilisez |cffDA8CFF/pm help|r pour plus d'informations.",
            ["VersionOutdated"] = "Votre version est obsolète. La dernière version peut être téléchargée sur https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "Je partage maintenant mes métiers avec Profession Master. Tapez « !who [objet] » et je pourrai peut-être vous dire qui peut le fabriquer pour vous.",
            ["LanguageNotSupported"] = "Malheureusement, la langue de votre client n'est pas prise en charge par ProfessionMaster.",
            ["You"] = "Vous",

            -- commands
            ["CommandsTitle"] = "Commandes disponibles :",
            ["CommandsOverview"] = "/pm - Afficher/Masquer l'aperçu des métiers",
            ["CommandsMinimap"] = "/pm minimap - Afficher l'icône de la minicarte",
            ["CommandsReagents"] = "/pm reagents - Afficher/Masquer les composants manquants",
            ["CommandsPurge"] = "/pm purge [all | own | <nom du joueur>] - Supprimer toutes les données, vos données ou celles d'un joueur spécifique",
            ["CommandsLogs"] = "/pm logs - Afficher les entrées du journal",
            ["CommandsPurgeRow1"] = "Commandes de suppression disponibles :",
            ["CommandsPurgeRow2"] = "/pm purge all - Supprimer toutes les données",
            ["CommandsPurgeRow3"] = "/pm purge own - Supprimer vos données",
            ["CommandsPurgeRow4"] = "/pm purge <nom du joueur> - Supprimer les données d'un joueur spécifique",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Bienvenue",
            ["WelcomeDescription"] = self.addon.name .. " vous montre vos métiers et ceux de tous les membres de votre guilde qui utilisent également " .. self.addon.name .. " dans un seul aperçu.\n\n" ..
                "Utilisez le bouton sur votre minicarte ou la commande de chat /pm pour afficher ou masquer les fenêtres correspondantes.\n\n" ..
                "|cffd4af37Ouvrez maintenant vos fenêtres de métiers pour partager vos métiers.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Clic gauche :|cffffffff Afficher l'aperçu|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Clic gauche :|cffffffff Ouvrir les paramètres|r",
            ["MinimapButtonRightClick"] = "|cff999999Clic droit :|cffffffff Afficher/Masquer les composants manquants|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Clic droit :|cffffffff Masquer le bouton de la minicarte|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Aperçu - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Métier",
            ["ProfessionsViewAllProfessions"] = "Tous les métiers",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Tous les addons",
            ["ProfessionsViewSearch"] = "Rechercher",
            ["ProfessionsViewItem"] = "Objet",
            ["ProfessionsViewEnchantment"] = "Enchantement",
            ["ProfessionsViewPlayers"] = "Joueurs",
            ["ProfessionsViewBucketList"] = "Liste de courses",
            ["ProfessionsViewMissingReagents"] = "Composants manquants",
            ["ProfessionsViewCraftSelf"] = "Fabriquer soi-même",
            ["ProfessionsViewRemoveFromWatchList"] = "Retirer de la liste de suivi",
            ["ProfessionsViewRemoveFromBucketList"] = "Retirer de la liste de courses",
            ["ProfessionsViewClearBucketList"] = "Vider la liste de courses",
            ["ProfessionsViewNotOnBucketList"] = "Autres",
            ["ProfessionsViewFooter"] = "|cffDA8CFFClic gauche : |cffffffffAfficher les détails.   |cffDA8CFFShift + Clic gauche : |cffffffffLien de l'objet dans le chat.   |cffDA8CFFCtrl + Shift + Clic gauche : |cffffffffLien de compétence dans le chat.",
            ["ProfessionsViewAnnounce"] = "Annoncer dans le chat de guilde",

            -- skill view
            ["SkillViewPlayers"] = "Joueurs",
            ["SkillViewOnBucketList"] = "Sur la liste de courses",
            ["SkillViewOk"] = "OK",
            ["SkillViewAddToBucketList"] = "Ajouter 1 à la liste de courses",
            ["SkillViewRemoveOneFromBucketList"] = "Retirer 1 de la liste de courses",
            ["SkillViewRemoveFromBucketList"] = "Retirer l'objet de la liste de courses",
            ["SkillViewRecipe"] = "Recette",
            ["SkillViewTaughtBy"] = "Appris par :",
            ["SkillViewTrainer"] = "Maître",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Composants manquants",

            -- help view
            ["HelpViewTitle"] = "Aide",
            ["HelpTooltip"] = "Afficher l'aide",
            ["CloseTooltip"] = "Fermer",

            -- purge
            ["AllDataPurged"] = "Toutes les données ont été supprimées",
            ["CharacterPurged"] = "Les données de %s ont été supprimées",
            ["PurgeViewTitle"] = "Purger les joueurs",
            ["PurgeViewDescription"] = "Sélectionnez les joueurs à supprimer :",
            ["PurgeButtonText"] = "Purger la sélection (%d)",
            ["PurgeNoStalePlayers"] = "Aucun joueur trouvé qui n'est plus dans la guilde.",
            ["PurgeHeaderNotInGuild"] = "Joueurs qui ne sont plus dans la guilde :",
            ["PurgeHeaderOtherPlayers"] = "Autres joueurs :",
            ["PurgeNoPlayersFound"] = "Aucun joueur trouvé.",
            ["PurgeDone"] = "%d joueur(s) purgé(s).",

            -- who
            ["WhoCraftResponse"] = "Je peux fabriquer ça pour vous !",
            ["WhoCannotCraftResponse"] = "Malheureusement, je ne connais personne qui puisse fabriquer cela.",
            ["WhoOtherCanCraftResponse"] = "peut fabriquer ça pour vous !",

            -- specializations
            ["Specialization"] = "Spécialisation",
            ["AllSpecializations"] = "Toutes les spécialisations",
            ["Spec28675"] = "Maître des potions",
            ["Spec28677"] = "Maître des élixirs",
            ["Spec28672"] = "Maître de la transmutation",
            ["Spec9788"] = "Forgeron d'armures",
            ["Spec9787"] = "Forgeron d'armes",
            ["Spec17039"] = "Maître épéiste",
            ["Spec17040"] = "Maître marteleur",
            ["Spec17041"] = "Maître des haches",
            ["Spec10656"] = "Travail du cuir d'écailles de dragon",
            ["Spec10658"] = "Travail du cuir élémentaire",
            ["Spec10660"] = "Travail du cuir tribal",
            ["Spec26797"] = "Couture de feu magique",
            ["Spec26801"] = "Couture de tisse-ombre",
            ["Spec26798"] = "Couture de tissu lunaire",
            ["Spec20219"] = "Ingénierie gnome",
            ["Spec20222"] = "Ingénierie gobeline",

            -- settings
            ["SettingsRespondToWho"] = "Répondre à !who",
            ["SettingsSendNonGuildCharacters"] = "Envoyer les métiers des personnages hors guilde",
            ["SettingsPurgeAll"] = "Supprimer toutes les données",
            ["SkillCacheUpdating"] = "Mise à jour des données...",
            ["SkillCacheUpdated"] = "%d données ont été mises à jour."
        },
        -- define it locale
        ["it"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " di Kurki. Usa |cffDA8CFF/pm help|r per maggiori informazioni.",
            ["VersionOutdated"] = "La tua versione è obsoleta. L'ultima versione può essere scaricata su https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "Ora condivido le mie professioni con Profession Master. Scrivi \"!who [oggetto]\" e forse potrò dirti chi può fabbricarlo per te.",
            ["LanguageNotSupported"] = "Purtroppo la lingua del tuo client non è supportata da ProfessionMaster.",
            ["You"] = "Tu",

            -- commands
            ["CommandsTitle"] = "Comandi disponibili:",
            ["CommandsOverview"] = "/pm - Mostra/Nascondi panoramica delle professioni",
            ["CommandsMinimap"] = "/pm minimap - Mostra icona della minimappa",
            ["CommandsReagents"] = "/pm reagents - Mostra/Nascondi reagenti mancanti",
            ["CommandsPurge"] = "/pm purge [all | own | <nome giocatore>] - Elimina tutti i dati, i tuoi dati o quelli di un giocatore specifico",
            ["CommandsLogs"] = "/pm logs - Mostra le voci del registro",
            ["CommandsPurgeRow1"] = "Comandi di eliminazione disponibili:",
            ["CommandsPurgeRow2"] = "/pm purge all - Elimina tutti i dati",
            ["CommandsPurgeRow3"] = "/pm purge own - Elimina i tuoi dati",
            ["CommandsPurgeRow4"] = "/pm purge <nome giocatore> - Elimina i dati di un giocatore specifico",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Benvenuto",
            ["WelcomeDescription"] = self.addon.name .. " ti mostra le tue professioni e quelle di tutti i membri della tua gilda che usano anche " .. self.addon.name .. " in un'unica panoramica.\n\n" ..
                "Usa il pulsante sulla minimappa o il comando chat /pm per mostrare o nascondere le finestre corrispondenti.\n\n" ..
                "|cffd4af37Apri ora le finestre delle tue professioni per condividerle.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Clic sinistro:|cffffffff Mostra panoramica|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Clic sinistro:|cffffffff Apri impostazioni|r",
            ["MinimapButtonRightClick"] = "|cff999999Clic destro:|cffffffff Mostra/Nascondi reagenti mancanti|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Clic destro:|cffffffff Nascondi pulsante della minimappa|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Panoramica - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Professione",
            ["ProfessionsViewAllProfessions"] = "Tutte le professioni",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Tutti gli addon",
            ["ProfessionsViewSearch"] = "Cerca",
            ["ProfessionsViewItem"] = "Oggetto",
            ["ProfessionsViewEnchantment"] = "Incantamento",
            ["ProfessionsViewPlayers"] = "Giocatori",
            ["ProfessionsViewBucketList"] = "Lista della spesa",
            ["ProfessionsViewMissingReagents"] = "Reagenti mancanti",
            ["ProfessionsViewCraftSelf"] = "Fabbrica tu stesso",
            ["ProfessionsViewRemoveFromWatchList"] = "Rimuovi dalla lista di osservazione",
            ["ProfessionsViewRemoveFromBucketList"] = "Rimuovi dalla lista della spesa",
            ["ProfessionsViewClearBucketList"] = "Svuota lista della spesa",
            ["ProfessionsViewNotOnBucketList"] = "Altro",
            ["ProfessionsViewFooter"] = "|cffDA8CFFClic sinistro: |cffffffffMostra dettagli.   |cffDA8CFFShift + Clic sinistro: |cffffffffLink oggetto nella chat.   |cffDA8CFFCtrl + Shift + Clic sinistro: |cffffffffLink abilità nella chat.",
            ["ProfessionsViewAnnounce"] = "Annuncia nella chat della gilda",

            -- skill view
            ["SkillViewPlayers"] = "Giocatori",
            ["SkillViewOnBucketList"] = "Nella lista della spesa",
            ["SkillViewOk"] = "OK",
            ["SkillViewAddToBucketList"] = "Aggiungi 1 alla lista della spesa",
            ["SkillViewRemoveOneFromBucketList"] = "Rimuovi 1 dalla lista della spesa",
            ["SkillViewRemoveFromBucketList"] = "Rimuovi oggetto dalla lista della spesa",
            ["SkillViewRecipe"] = "Ricetta",
            ["SkillViewTaughtBy"] = "Insegnato da:",
            ["SkillViewTrainer"] = "Istruttore",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Reagenti mancanti",

            -- help view
            ["HelpViewTitle"] = "Aiuto",
            ["HelpTooltip"] = "Mostra aiuto",
            ["CloseTooltip"] = "Chiudi",

            -- purge
            ["AllDataPurged"] = "Tutti i dati sono stati eliminati",
            ["CharacterPurged"] = "I dati di %s sono stati eliminati",
            ["PurgeViewTitle"] = "Elimina giocatori",
            ["PurgeViewDescription"] = "Seleziona i giocatori da rimuovere:",
            ["PurgeButtonText"] = "Elimina selezionati (%d)",
            ["PurgeNoStalePlayers"] = "Nessun giocatore trovato che non \195\168 pi\195\185 nella gilda.",
            ["PurgeHeaderNotInGuild"] = "Giocatori non più nella gilda:",
            ["PurgeHeaderOtherPlayers"] = "Altri giocatori:",
            ["PurgeNoPlayersFound"] = "Nessun giocatore trovato.",
            ["PurgeDone"] = "%d giocatore/i eliminato/i.",

            -- who
            ["WhoCraftResponse"] = "Posso fabbricarlo per te!",
            ["WhoCannotCraftResponse"] = "Purtroppo non conosco nessuno che possa fabbricarlo.",
            ["WhoOtherCanCraftResponse"] = "può fabbricarlo per te!",

            -- specializations
            ["Specialization"] = "Specializzazione",
            ["AllSpecializations"] = "Tutte le specializzazioni",
            ["Spec28675"] = "Maestro delle pozioni",
            ["Spec28677"] = "Maestro degli elisir",
            ["Spec28672"] = "Maestro della trasmutazione",
            ["Spec9788"] = "Forgiatore di armature",
            ["Spec9787"] = "Forgiatore di armi",
            ["Spec17039"] = "Maestro spadaio",
            ["Spec17040"] = "Maestro del martello",
            ["Spec17041"] = "Maestro dell'ascia",
            ["Spec10656"] = "Lavorazione pelle di drago",
            ["Spec10658"] = "Lavorazione pelle elementale",
            ["Spec10660"] = "Lavorazione pelle tribale",
            ["Spec26797"] = "Sartoria del fuoco magico",
            ["Spec26801"] = "Sartoria dell'ombra",
            ["Spec26798"] = "Sartoria della stoffa lunare",
            ["Spec20219"] = "Ingegneria gnomesca",
            ["Spec20222"] = "Ingegneria goblin",

            -- settings
            ["SettingsRespondToWho"] = "Rispondi a !who",
            ["SettingsSendNonGuildCharacters"] = "Invia professioni dei personaggi fuori dalla gilda",
            ["SettingsPurgeAll"] = "Elimina tutti i dati",
            ["SkillCacheUpdating"] = "Aggiornamento dati in corso...",
            ["SkillCacheUpdated"] = "%d dati sono stati aggiornati."
        },
        -- define ko locale
        ["ko"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " 제작: Kurki. |cffDA8CFF/pm help|r 명령어로 자세한 정보를 확인하세요.",
            ["VersionOutdated"] = "버전이 오래되었습니다. 최신 버전은 https://www.curseforge.com/wow/addons/profession-master 에서 다운로드할 수 있습니다.",
            ["GuildAnnouncement"] = "Profession Master로 전문 기술을 공유합니다. \"!who [아이템]\"을 입력하면 누가 제작할 수 있는지 알려드릴 수 있습니다.",
            ["LanguageNotSupported"] = "죄송합니다. 클라이언트 언어가 ProfessionMaster에서 지원되지 않습니다.",
            ["You"] = "나",

            -- commands
            ["CommandsTitle"] = "사용 가능한 명령어:",
            ["CommandsOverview"] = "/pm - 전문 기술 개요 표시/숨기기",
            ["CommandsMinimap"] = "/pm minimap - 미니맵 아이콘 표시",
            ["CommandsReagents"] = "/pm reagents - 부족한 재료 표시/숨기기",
            ["CommandsPurge"] = "/pm purge [all | own | <플레이어 이름>] - 모든 데이터, 내 데이터 또는 특정 플레이어의 데이터 삭제",
            ["CommandsLogs"] = "/pm logs - 로그 항목 표시",
            ["CommandsPurgeRow1"] = "사용 가능한 삭제 명령어:",
            ["CommandsPurgeRow2"] = "/pm purge all - 모든 데이터 삭제",
            ["CommandsPurgeRow3"] = "/pm purge own - 내 데이터 삭제",
            ["CommandsPurgeRow4"] = "/pm purge <플레이어 이름> - 특정 플레이어의 데이터 삭제",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - 환영합니다",
            ["WelcomeDescription"] = self.addon.name .. "은(는) " .. self.addon.name .. "을(를) 사용하는 모든 길드원의 전문 기술을 한눈에 보여줍니다.\n\n" ..
                "미니맵 버튼이나 채팅 명령어 /pm을 사용하여 해당 창을 표시하거나 숨길 수 있습니다.\n\n" ..
                "|cffd4af37지금 전문 기술 창을 열어 전문 기술을 공유하세요.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999좌클릭:|cffffffff 개요 표시|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + 좌클릭:|cffffffff 설정 열기|r",
            ["MinimapButtonRightClick"] = "|cff999999우클릭:|cffffffff 부족한 재료 표시/숨기기|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + 우클릭:|cffffffff 미니맵 버튼 숨기기|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - 개요 - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "전문 기술",
            ["ProfessionsViewAllProfessions"] = "모든 전문 기술",
            ["ProfessionsViewAddon"] = "애드온",
            ["ProfessionsViewAllAddons"] = "모든 애드온",
            ["ProfessionsViewSearch"] = "검색",
            ["ProfessionsViewItem"] = "아이템",
            ["ProfessionsViewEnchantment"] = "마법부여",
            ["ProfessionsViewPlayers"] = "플레이어",
            ["ProfessionsViewBucketList"] = "구매 목록",
            ["ProfessionsViewMissingReagents"] = "부족한 재료",
            ["ProfessionsViewCraftSelf"] = "직접 제작",
            ["ProfessionsViewRemoveFromWatchList"] = "관심 목록에서 제거",
            ["ProfessionsViewRemoveFromBucketList"] = "구매 목록에서 제거",
            ["ProfessionsViewClearBucketList"] = "구매 목록 비우기",
            ["ProfessionsViewNotOnBucketList"] = "기타",
            ["ProfessionsViewFooter"] = "|cffDA8CFF좌클릭: |cffffffff상세 보기.   |cffDA8CFFShift + 좌클릭: |cffffffff채팅에 아이템 링크.   |cffDA8CFFCtrl + Shift + 좌클릭: |cffffffff채팅에 기술 링크.",
            ["ProfessionsViewAnnounce"] = "길드 채팅에 홍보",

            -- skill view
            ["SkillViewPlayers"] = "플레이어",
            ["SkillViewOnBucketList"] = "구매 목록에 있음",
            ["SkillViewOk"] = "확인",
            ["SkillViewAddToBucketList"] = "구매 목록에 1개 추가",
            ["SkillViewRemoveOneFromBucketList"] = "구매 목록에서 1개 제거",
            ["SkillViewRemoveFromBucketList"] = "구매 목록에서 아이템 제거",
            ["SkillViewRecipe"] = "레시피",
            ["SkillViewTaughtBy"] = "배우는 경로:",
            ["SkillViewTrainer"] = "훈련사",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "부족한 재료",

            -- help view
            ["HelpViewTitle"] = "도움말",
            ["HelpTooltip"] = "도움말 표시",
            ["CloseTooltip"] = "닫기",

            -- purge
            ["AllDataPurged"] = "모든 데이터가 삭제되었습니다",
            ["CharacterPurged"] = "%s의 데이터가 삭제되었습니다",
            ["PurgeViewTitle"] = "플레이어 정리",
            ["PurgeViewDescription"] = "삭제할 플레이어를 선택하세요:",
            ["PurgeButtonText"] = "선택된 항목 삭제 (%d)",
            ["PurgeNoStalePlayers"] = "길드에 없는 플레이어가 없습니다.",
            ["PurgeHeaderNotInGuild"] = "더 이상 길드에 없는 플레이어:",
            ["PurgeHeaderOtherPlayers"] = "다른 플레이어:",
            ["PurgeNoPlayersFound"] = "플레이어를 찾을 수 없습니다.",
            ["PurgeDone"] = "%d명의 플레이어가 삭제되었습니다.",

            -- who
            ["WhoCraftResponse"] = "제가 제작해 드릴 수 있습니다!",
            ["WhoCannotCraftResponse"] = "죄송합니다, 제작할 수 있는 사람을 모릅니다.",
            ["WhoOtherCanCraftResponse"] = "님이 제작해 드릴 수 있습니다!",

            -- specializations
            ["Specialization"] = "전문화",
            ["AllSpecializations"] = "모든 전문화",
            ["Spec28675"] = "물약의 대가",
            ["Spec28677"] = "비약의 대가",
            ["Spec28672"] = "변환의 대가",
            ["Spec9788"] = "방어구 대장장이",
            ["Spec9787"] = "무기 대장장이",
            ["Spec17039"] = "검 제작의 대가",
            ["Spec17040"] = "망치 제작의 대가",
            ["Spec17041"] = "도끼 제작의 대가",
            ["Spec10656"] = "용비늘 가죽세공",
            ["Spec10658"] = "원소 가죽세공",
            ["Spec10660"] = "부족 가죽세공",
            ["Spec26797"] = "마법불꽃 재봉술",
            ["Spec26801"] = "그림자매듭 재봉술",
            ["Spec26798"] = "달빛매듭 재봉술",
            ["Spec20219"] = "노움 공학",
            ["Spec20222"] = "고블린 공학",

            -- settings
            ["SettingsRespondToWho"] = "!who에 응답",
            ["SettingsSendNonGuildCharacters"] = "길드 외 캐릭터의 전문 기술 전송",
            ["SettingsPurgeAll"] = "모든 데이터 삭제",
            ["SkillCacheUpdating"] = "데이터 업데이트 중...",
            ["SkillCacheUpdated"] = "%d개의 데이터가 업데이트되었습니다."
        },
        -- define pt locale
        ["pt"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " por Kurki. Use |cffDA8CFF/pm help|r para mais informações.",
            ["VersionOutdated"] = "Sua versão está desatualizada. A versão mais recente pode ser baixada em https://www.curseforge.com/wow/addons/profession-master.",
            ["GuildAnnouncement"] = "Agora estou compartilhando minhas profissões com o Profession Master. Digite \"!who [item]\" e talvez eu possa dizer quem pode fabricar isso para você.",
            ["LanguageNotSupported"] = "Infelizmente, o idioma do seu cliente não é suportado pelo ProfessionMaster.",
            ["You"] = "Você",

            -- commands
            ["CommandsTitle"] = "Comandos disponíveis:",
            ["CommandsOverview"] = "/pm - Mostrar/Ocultar visão geral das profissões",
            ["CommandsMinimap"] = "/pm minimap - Mostrar ícone do minimapa",
            ["CommandsReagents"] = "/pm reagents - Mostrar/Ocultar reagentes faltantes",
            ["CommandsPurge"] = "/pm purge [all | own | <nome do jogador>] - Apagar todos os dados, seus dados ou de um jogador específico",
            ["CommandsLogs"] = "/pm logs - Mostrar entradas do registro",
            ["CommandsPurgeRow1"] = "Comandos de exclusão disponíveis:",
            ["CommandsPurgeRow2"] = "/pm purge all - Apagar todos os dados",
            ["CommandsPurgeRow3"] = "/pm purge own - Apagar seus dados",
            ["CommandsPurgeRow4"] = "/pm purge <nome do jogador> - Apagar dados de um jogador específico",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - Bem-vindo",
            ["WelcomeDescription"] = self.addon.name .. " mostra suas profissões e as de todos os membros da sua guilda que também usam " .. self.addon.name .. " em uma única visão geral.\n\n" ..
                "Use o botão no minimapa ou o comando de chat /pm para mostrar ou ocultar as janelas correspondentes.\n\n" ..
                "|cffd4af37Abra agora as janelas de profissões para compartilhar suas profissões.",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999Clique esquerdo:|cffffffff Mostrar visão geral|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + Clique esquerdo:|cffffffff Abrir configurações|r",
            ["MinimapButtonRightClick"] = "|cff999999Clique direito:|cffffffff Mostrar/Ocultar reagentes faltantes|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + Clique direito:|cffffffff Ocultar botão do minimapa|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - Visão geral - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "Profissão",
            ["ProfessionsViewAllProfessions"] = "Todas as profissões",
            ["ProfessionsViewAddon"] = "Addon",
            ["ProfessionsViewAllAddons"] = "Todos os addons",
            ["ProfessionsViewSearch"] = "Pesquisar",
            ["ProfessionsViewItem"] = "Item",
            ["ProfessionsViewEnchantment"] = "Encantamento",
            ["ProfessionsViewPlayers"] = "Jogadores",
            ["ProfessionsViewBucketList"] = "Lista de compras",
            ["ProfessionsViewMissingReagents"] = "Reagentes faltantes",
            ["ProfessionsViewCraftSelf"] = "Fabricar você mesmo",
            ["ProfessionsViewRemoveFromWatchList"] = "Remover da lista de observação",
            ["ProfessionsViewRemoveFromBucketList"] = "Remover da lista de compras",
            ["ProfessionsViewClearBucketList"] = "Limpar lista de compras",
            ["ProfessionsViewNotOnBucketList"] = "Outros",
            ["ProfessionsViewFooter"] = "|cffDA8CFFClique esquerdo: |cffffffffMostrar detalhes.   |cffDA8CFFShift + Clique esquerdo: |cffffffffLink do item no chat.   |cffDA8CFFCtrl + Shift + Clique esquerdo: |cffffffffLink da habilidade no chat.",
            ["ProfessionsViewAnnounce"] = "Anunciar no chat da guilda",

            -- skill view
            ["SkillViewPlayers"] = "Jogadores",
            ["SkillViewOnBucketList"] = "Na lista de compras",
            ["SkillViewOk"] = "OK",
            ["SkillViewAddToBucketList"] = "Adicionar 1 à lista de compras",
            ["SkillViewRemoveOneFromBucketList"] = "Remover 1 da lista de compras",
            ["SkillViewRemoveFromBucketList"] = "Remover item da lista de compras",
            ["SkillViewRecipe"] = "Receita",
            ["SkillViewTaughtBy"] = "Ensinado por:",
            ["SkillViewTrainer"] = "Treinador",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "Reagentes faltantes",

            -- help view
            ["HelpViewTitle"] = "Ajuda",
            ["HelpTooltip"] = "Mostrar ajuda",
            ["CloseTooltip"] = "Fechar",

            -- purge
            ["AllDataPurged"] = "Todos os dados foram apagados",
            ["CharacterPurged"] = "Os dados de %s foram apagados",
            ["PurgeViewTitle"] = "Limpar jogadores",
            ["PurgeViewDescription"] = "Selecione os jogadores a remover:",
            ["PurgeButtonText"] = "Limpar selecionados (%d)",
            ["PurgeNoStalePlayers"] = "Nenhum jogador encontrado que não está mais na guilda.",
            ["PurgeHeaderNotInGuild"] = "Jogadores que não estão mais na guilda:",
            ["PurgeHeaderOtherPlayers"] = "Outros jogadores:",
            ["PurgeNoPlayersFound"] = "Nenhum jogador encontrado.",
            ["PurgeDone"] = "%d jogador(es) removido(s).",

            -- who
            ["WhoCraftResponse"] = "Posso fabricar isso para você!",
            ["WhoCannotCraftResponse"] = "Infelizmente, não conheço ninguém que possa fabricar isso.",
            ["WhoOtherCanCraftResponse"] = "pode fabricar isso para você!",

            -- specializations
            ["Specialization"] = "Especialização",
            ["AllSpecializations"] = "Todas as especializações",
            ["Spec28675"] = "Mestre em poções",
            ["Spec28677"] = "Mestre em elixires",
            ["Spec28672"] = "Mestre em transmutação",
            ["Spec9788"] = "Ferreiro de armaduras",
            ["Spec9787"] = "Ferreiro de armas",
            ["Spec17039"] = "Mestre espadachim",
            ["Spec17040"] = "Mestre dos martelos",
            ["Spec17041"] = "Mestre dos machados",
            ["Spec10656"] = "Couraria de escamas de dragão",
            ["Spec10658"] = "Couraria elemental",
            ["Spec10660"] = "Couraria tribal",
            ["Spec26797"] = "Alfaiataria de fogo arcano",
            ["Spec26801"] = "Alfaiataria de teia de sombras",
            ["Spec26798"] = "Alfaiataria de tecido lunar",
            ["Spec20219"] = "Engenharia gnômica",
            ["Spec20222"] = "Engenharia goblin",

            -- settings
            ["SettingsRespondToWho"] = "Responder a !who",
            ["SettingsSendNonGuildCharacters"] = "Enviar profissões de personagens fora da guilda",
            ["SettingsPurgeAll"] = "Apagar todos os dados",
            ["SkillCacheUpdating"] = "Atualizando dados...",
            ["SkillCacheUpdated"] = "%d dados foram atualizados."
        },
        -- define zhCN locale (Simplified Chinese)
        ["zhCN"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " 作者 Kurki。使用 |cffDA8CFF/pm help|r 获取更多信息。",
            ["VersionOutdated"] = "你的版本已过期。最新版本可在 https://www.curseforge.com/wow/addons/profession-master 下载。",
            ["GuildAnnouncement"] = "我正在通过 Profession Master 分享我的专业技能。输入\"/who [物品]\"，我也许能告诉你谁可以为你制作。",
            ["LanguageNotSupported"] = "很遗憾，ProfessionMaster 不支持你客户端的语言。",
            ["You"] = "你",

            -- commands
            ["CommandsTitle"] = "可用命令：",
            ["CommandsOverview"] = "/pm - 显示/隐藏专业技能概览",
            ["CommandsMinimap"] = "/pm minimap - 显示小地图图标",
            ["CommandsReagents"] = "/pm reagents - 显示/隐藏缺少的材料",
            ["CommandsPurge"] = "/pm purge [all | own | <玩家名称>] - 删除所有数据、你的数据或特定玩家的数据",
            ["CommandsLogs"] = "/pm logs - 显示日志条目",
            ["CommandsPurgeRow1"] = "可用的删除命令：",
            ["CommandsPurgeRow2"] = "/pm purge all - 删除所有数据",
            ["CommandsPurgeRow3"] = "/pm purge own - 删除你的数据",
            ["CommandsPurgeRow4"] = "/pm purge <玩家名称> - 删除特定玩家的数据",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - 欢迎",
            ["WelcomeDescription"] = self.addon.name .. " 在一个界面中显示你的专业技能以及所有同样使用 " .. self.addon.name .. " 的公会成员的专业技能。\n\n" ..
                "使用小地图按钮或聊天命令 /pm 来显示或隐藏相应窗口。\n\n" ..
                "|cffd4af37现在打开你的专业技能窗口以分享你的专业技能。",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999左键点击：|cffffffff 显示概览|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + 左键点击：|cffffffff 打开设置|r",
            ["MinimapButtonRightClick"] = "|cff999999右键点击：|cffffffff 显示/隐藏缺少的材料|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + 右键点击：|cffffffff 隐藏小地图按钮|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - 概览 - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "专业技能",
            ["ProfessionsViewAllProfessions"] = "所有专业技能",
            ["ProfessionsViewAddon"] = "插件",
            ["ProfessionsViewAllAddons"] = "所有插件",
            ["ProfessionsViewSearch"] = "搜索",
            ["ProfessionsViewItem"] = "物品",
            ["ProfessionsViewEnchantment"] = "附魔",
            ["ProfessionsViewPlayers"] = "玩家",
            ["ProfessionsViewBucketList"] = "购物清单",
            ["ProfessionsViewMissingReagents"] = "缺少的材料",
            ["ProfessionsViewCraftSelf"] = "自己制作",
            ["ProfessionsViewRemoveFromWatchList"] = "从关注列表中移除",
            ["ProfessionsViewRemoveFromBucketList"] = "从购物清单中移除",
            ["ProfessionsViewClearBucketList"] = "清空购物清单",
            ["ProfessionsViewNotOnBucketList"] = "其他",
            ["ProfessionsViewFooter"] = "|cffDA8CFF左键点击：|cffffffff显示详情。   |cffDA8CFFShift + 左键点击：|cffffffff在聊天中发送物品链接。   |cffDA8CFFCtrl + Shift + 左键点击：|cffffffff在聊天中发送技能链接。",
            ["ProfessionsViewAnnounce"] = "在公会聊天中宣传",

            -- skill view
            ["SkillViewPlayers"] = "玩家",
            ["SkillViewOnBucketList"] = "已在购物清单中",
            ["SkillViewOk"] = "确定",
            ["SkillViewAddToBucketList"] = "向购物清单添加1个",
            ["SkillViewRemoveOneFromBucketList"] = "从购物清单移除1个",
            ["SkillViewRemoveFromBucketList"] = "从购物清单移除物品",
            ["SkillViewRecipe"] = "配方",
            ["SkillViewTaughtBy"] = "学习途径：",
            ["SkillViewTrainer"] = "训练师",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "缺少的材料",

            -- help view
            ["HelpViewTitle"] = "帮助",
            ["HelpTooltip"] = "显示帮助",
            ["CloseTooltip"] = "关闭",

            -- purge
            ["AllDataPurged"] = "所有数据已删除",
            ["CharacterPurged"] = "%s 的数据已删除",
            ["PurgeViewTitle"] = "清理玩家",
            ["PurgeViewDescription"] = "选择要移除的玩家：",
            ["PurgeButtonText"] = "清理已选 (%d)",
            ["PurgeNoStalePlayers"] = "没有找到不再在公会中的玩家。",
            ["PurgeHeaderNotInGuild"] = "不再在公会中的玩家：",
            ["PurgeHeaderOtherPlayers"] = "其他玩家：",
            ["PurgeNoPlayersFound"] = "未找到玩家。",
            ["PurgeDone"] = "已清理 %d 名玩家。",

            -- who
            ["WhoCraftResponse"] = "我可以为你制作！",
            ["WhoCannotCraftResponse"] = "很遗憾，我不知道谁能制作这个。",
            ["WhoOtherCanCraftResponse"] = "可以为你制作！",

            -- specializations
            ["Specialization"] = "专精",
            ["AllSpecializations"] = "所有专精",
            ["Spec28675"] = "药水大师",
            ["Spec28677"] = "药剂大师",
            ["Spec28672"] = "转化大师",
            ["Spec9788"] = "护甲锻造师",
            ["Spec9787"] = "武器锻造师",
            ["Spec17039"] = "铸剑大师",
            ["Spec17040"] = "铸锤大师",
            ["Spec17041"] = "铸斧大师",
            ["Spec10656"] = "龙鳞制皮",
            ["Spec10658"] = "元素制皮",
            ["Spec10660"] = "部族制皮",
            ["Spec26797"] = "魔焰裁缝",
            ["Spec26801"] = "暗影裁缝",
            ["Spec26798"] = "月布裁缝",
            ["Spec20219"] = "侏儒工程学",
            ["Spec20222"] = "地精工程学",

            -- settings
            ["SettingsRespondToWho"] = "响应 !who",
            ["SettingsSendNonGuildCharacters"] = "发送公会外角色的专业技能",
            ["SettingsPurgeAll"] = "删除所有数据",
            ["SkillCacheUpdating"] = "数据正在更新...",
            ["SkillCacheUpdated"] = "已更新 %d 条数据。"
        },
        -- define zhTW locale (Traditional Chinese)
        ["zhTW"] = {
            -- general
            ["AddonLoaded"] = "v" .. self.addon.version .. " 作者 Kurki。使用 |cffDA8CFF/pm help|r 獲取更多資訊。",
            ["VersionOutdated"] = "你的版本已過期。最新版本可在 https://www.curseforge.com/wow/addons/profession-master 下載。",
            ["GuildAnnouncement"] = "我正在透過 Profession Master 分享我的專業技能。輸入\"!who [物品]\"，我也許能告訴你誰可以為你製作。",
            ["LanguageNotSupported"] = "很遺憾，ProfessionMaster 不支援你客戶端的語言。",
            ["You"] = "你",

            -- commands
            ["CommandsTitle"] = "可用指令：",
            ["CommandsOverview"] = "/pm - 顯示/隱藏專業技能概覽",
            ["CommandsMinimap"] = "/pm minimap - 顯示小地圖圖示",
            ["CommandsReagents"] = "/pm reagents - 顯示/隱藏缺少的材料",
            ["CommandsPurge"] = "/pm purge [all | own | <玩家名稱>] - 刪除所有資料、你的資料或特定玩家的資料",
            ["CommandsLogs"] = "/pm logs - 顯示日誌條目",
            ["CommandsPurgeRow1"] = "可用的刪除指令：",
            ["CommandsPurgeRow2"] = "/pm purge all - 刪除所有資料",
            ["CommandsPurgeRow3"] = "/pm purge own - 刪除你的資料",
            ["CommandsPurgeRow4"] = "/pm purge <玩家名稱> - 刪除特定玩家的資料",

            -- welcome
            ["WelcomeTitle"] = self.addon.name .. " - 歡迎",
            ["WelcomeDescription"] = self.addon.name .. " 在一個介面中顯示你的專業技能以及所有同樣使用 " .. self.addon.name .. " 的公會成員的專業技能。\n\n" ..
                "使用小地圖按鈕或聊天指令 /pm 來顯示或隱藏對應的視窗。\n\n" ..
                "|cffd4af37現在打開你的專業技能視窗以分享你的專業技能。",

            -- minimap button
            ["MinimapButtonTitle"] = self.addon.shortcut .. self.addon.name,
            ["MinimapButtonLeftClick"] = "|cff999999左鍵點擊：|cffffffff 顯示概覽|r",
            ["MinimapButtonShiftLeftClick"] = "|cff999999Shift + 左鍵點擊：|cffffffff 開啟設定|r",
            ["MinimapButtonRightClick"] = "|cff999999右鍵點擊：|cffffffff 顯示/隱藏缺少的材料|r",
            ["MinimapButtonShiftRightClick"] = "|cff999999Shift + 右鍵點擊：|cffffffff 隱藏小地圖按鈕|r",

            -- profession view
            ["ProfessionsViewTitle"] = "|cffDA8CFFProfession Master|cffffffff - 概覽 - v" .. self.addon.version,
            ["ProfessionsViewProfession"] = "專業技能",
            ["ProfessionsViewAllProfessions"] = "所有專業技能",
            ["ProfessionsViewAddon"] = "插件",
            ["ProfessionsViewAllAddons"] = "所有插件",
            ["ProfessionsViewSearch"] = "搜尋",
            ["ProfessionsViewItem"] = "物品",
            ["ProfessionsViewEnchantment"] = "附魔",
            ["ProfessionsViewPlayers"] = "玩家",
            ["ProfessionsViewBucketList"] = "購物清單",
            ["ProfessionsViewMissingReagents"] = "缺少的材料",
            ["ProfessionsViewCraftSelf"] = "自己製作",
            ["ProfessionsViewRemoveFromWatchList"] = "從關注列表中移除",
            ["ProfessionsViewRemoveFromBucketList"] = "從購物清單中移除",
            ["ProfessionsViewClearBucketList"] = "清空購物清單",
            ["ProfessionsViewNotOnBucketList"] = "其他",
            ["ProfessionsViewFooter"] = "|cffDA8CFF左鍵點擊：|cffffffff顯示詳情。   |cffDA8CFFShift + 左鍵點擊：|cffffffff在聊天中發送物品連結。   |cffDA8CFFCtrl + Shift + 左鍵點擊：|cffffffff在聊天中發送技能連結。",
            ["ProfessionsViewAnnounce"] = "在公會聊天中宣傳",

            -- skill view
            ["SkillViewPlayers"] = "玩家",
            ["SkillViewOnBucketList"] = "已在購物清單中",
            ["SkillViewOk"] = "確定",
            ["SkillViewAddToBucketList"] = "向購物清單添加1個",
            ["SkillViewRemoveOneFromBucketList"] = "從購物清單移除1個",
            ["SkillViewRemoveFromBucketList"] = "從購物清單移除物品",
            ["SkillViewRecipe"] = "配方",
            ["SkillViewTaughtBy"] = "學習途徑：",
            ["SkillViewTrainer"] = "訓練師",

            -- missing reagents view
            ["MissingReagentsViewTitle"] = "缺少的材料",

            -- help view
            ["HelpViewTitle"] = "說明",
            ["HelpTooltip"] = "顯示說明",
            ["CloseTooltip"] = "關閉",

            -- purge
            ["AllDataPurged"] = "所有資料已刪除",
            ["CharacterPurged"] = "%s 的資料已刪除",
            ["PurgeViewTitle"] = "清理玩家",
            ["PurgeViewDescription"] = "選擇要移除的玩家：",
            ["PurgeButtonText"] = "清理已選 (%d)",
            ["PurgeNoStalePlayers"] = "沒有找到不再在公會中的玩家。",
            ["PurgeHeaderNotInGuild"] = "不再在公會中的玩家：",
            ["PurgeHeaderOtherPlayers"] = "其他玩家：",
            ["PurgeNoPlayersFound"] = "未找到玩家。",
            ["PurgeDone"] = "已清理 %d 名玩家。",

            -- who
            ["WhoCraftResponse"] = "我可以為你製作！",
            ["WhoCannotCraftResponse"] = "很遺憾，我不知道誰能製作這個。",
            ["WhoOtherCanCraftResponse"] = "可以為你製作！",

            -- specializations
            ["Specialization"] = "專精",
            ["AllSpecializations"] = "所有專精",
            ["Spec28675"] = "藥水大師",
            ["Spec28677"] = "藥劑大師",
            ["Spec28672"] = "轉化大師",
            ["Spec9788"] = "護甲鍛造師",
            ["Spec9787"] = "武器鍛造師",
            ["Spec17039"] = "鑄劍大師",
            ["Spec17040"] = "鑄錘大師",
            ["Spec17041"] = "鑄斧大師",
            ["Spec10656"] = "龍鱗製皮",
            ["Spec10658"] = "元素製皮",
            ["Spec10660"] = "部族製皮",
            ["Spec26797"] = "魔焰裁縫",
            ["Spec26801"] = "暗影裁縫",
            ["Spec26798"] = "月布裁縫",
            ["Spec20219"] = "乘儒工程學",
            ["Spec20222"] = "乘精工程學",

            -- settings
            ["SettingsRespondToWho"] = "回應 !who",
            ["SettingsSendNonGuildCharacters"] = "發送公會外角色的專業技能",
            ["SettingsPurgeAll"] = "刪除所有資料",
            ["SkillCacheUpdating"] = "資料正在更新...",
            ["SkillCacheUpdated"] = "已更新 %d 筆資料。"
        }
    };
end
