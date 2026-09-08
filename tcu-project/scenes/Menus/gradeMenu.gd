class_name GradeMenu
extends MenuBar

#region BASICS

func createMenu(menu_title : String = "") -> PopupMenu:
	var m_menu : PopupMenu = PopupMenu.new()
	setMenuTitle(m_menu, menu_title)
	
	if m_menu:
		return m_menu
	else:
		printerr("[GRADE MENU] Error: Could not create menu!\n")
		return null

func createSubMenu(sub_menu_title : String = "") -> PopupMenu:
	var s_menu : PopupMenu = PopupMenu.new()
	setSubMenuTitle(s_menu, sub_menu_title)
	
	if s_menu:
		return s_menu
	else:
		printerr("[GRADE MENU] Error: Could not create submenu!\n")
		return null

func addMenuItem(m_menu : PopupMenu = null, s_menu : PopupMenu = null):
	if m_menu:
		m_menu.add_submenu_node_item(s_menu.name, s_menu)
	else:
		printerr("[GRADE MENU] Error: Could not add item to menu! (Menu is NULL)\n")

func addSubMenuItem(s_menu : PopupMenu = null, sub_item_title : String = ""):
	if s_menu:
		s_menu.add_item(sub_item_title)
	else:
		printerr("[GRADE MENU] Error: Could not add item to submenu! (Submenu is NULL)\n")

#endregion

#region TITLE SETTING

func setSubMenuTitle(s_menu : PopupMenu = null, new_sub_title : String = ""):
	if s_menu:
		s_menu.name = new_sub_title

func setMenuTitle(m_menu : PopupMenu = null, new_title : String = ""):
	if m_menu:
		m_menu.name = new_title

#endregion
