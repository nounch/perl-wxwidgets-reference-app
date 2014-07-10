# Notes:
#
# 1.
# SavePerspective() -> string -> file
# LoadPerspective() <- string <- file
# ('Save view' button/menu entry)
#
# 2.
# 'Hide'/'Show' menu entries for panes
# (call Hide() andd Show() on pane(s))
#
# 3.
# Manual layouting:
# Left(), Top(), different rows for the
# panes
#
# 4.
# Proportions:
# undocumented: dock_proportion




package MainFrame;

use 5.010;
use strict;
use warnings;

use Wx 0.15 qw[:allclasses];
use Wx qw[:everything];

use CustomGrid;

use base qw(Wx::Frame);

use constant INPUT_FILE1 => "input1.txt";
use constant INPUT_FILE2 => "input2.txt";
use constant INPUT_FILE3 => "input3.txt";
use constant GRID_TEST_FILE1 => "gridTest1.txt";

use constant LOG_FILE => "log.txt";
use constant SB_FIELDS => 3;
use constant SET_BG_COLOR_ID => wxID_HIGHEST + 1;

sub new {
    my ($self, $parent, $id, $title, $pos, $size, $style, $name) = @_;
    $parent = undef unless defined $parent;
    $id = -1 unless defined $id;
    $title = "" unless defined $title;
    $pos = wxDefaultPosition unless defined $pos;
    $size = wxDefaultSize unless defined $size;
    $name = "" unless defined $name;

    $style = wxDEFAULT_FRAME_STYLE;

    $self = $self->SUPER::new($parent, $id, $title, $pos, $size, $style, $name);

    # Package variables
    $self->{itemText} = "";

    # $self->{mainPanel} = Wx::Panel->new($self, wxID_ANY, wxDefaultPosition,
    # 					wxDefaultSize, wxTAB_TRAVERSAL,
    # 					"mainPanel");

    $self->{auiManager} = Wx::AuiManager->new($self, wxAUI_MGR_ALLOW_FLOATING |
    					      wxAUI_MGR_RECTANGLE_HINT |
    					      # wxAUI_MGR_HINT_FADE |
    					      wxAUI_MGR_NO_VENETIAN_BLINDS_FADE);

    $self->{filesPanel} = Wx::Panel->new($self, -1, wxDefaultPosition,
					 wxDefaultSize, wxEXPAND,
					 "filesPanel");

    $self->{filesNotebook} = Wx::AuiNotebook->new($self->{filesPanel}, wxID_ANY,
    						  wxDefaultPosition,
    						  wxDefaultSize,
						  wxAUI_NB_DEFAULT_STYLE);

    # wxAUI_MGR_ALLOW_FLOATING |
    # wxAUI_MGR_RECTANGLE_HINT |
    # wxAUI_MGR_HINT_FADE) |
    # wxAUI_MGR_NO_VENETIAN_BLINDS_FADE |
    # wxAUI_NB_TAB_SPLIT);

    # Causes Segmentation fault (invalid pointer)
    $self->{notebookManager} = $self->{filesNotebook}->GetAuiManager();
    $self->{notebookManager}->SetFlags(wxAUI_MGR_RECTANGLE_HINT);
    $self->{notebookManager}->Update();

    $self->{menuBar} = Wx::MenuBar->new(); # wxMB_DOCKABLE makes it dockable
    $self->{fileMenu} = Wx::Menu->new();
    $self->{colorMenu} = Wx::Menu->new();

    $self->CreateToolBar(wxNO_BORDER | wxTB_HORIZONTAL, -1, "toolBar");
    my @colours = ("Red", "Green", "Blue");
    my $coloursRef = \@colours;
    $self->{toolBarComboBox} = Wx::ComboBox->new($self->GetToolBar(), -1, "Red",
						 wxDefaultPosition,
						 wxDefaultSize, $coloursRef,
						 0, wxDefaultValidator,
						 "toolBarComboBox");
    $self->GetToolBar()->AddControl($self->{toolBarComboBox});
    # $self->GetToolBar()->AddTool(0, "Test tool", wxNullBitmap,
    # 				 "This is a test tool", wxITEM_NORMAL);
    $self->GetToolBar()->Realize();

    $self->{statusBar} = Wx::StatusBar->new($self, -1, wxST_SIZEGRIP,
					    "statusBar");

    $self->{fileDialog} = Wx::FileDialog->new($self, "Open file", ".", "",
    					      "*.*", wxFD_DEFAULT_STYLE,
    					      wxDefaultPosition);

    # $self->{mainPanel} = Wx::Panel->new($self, -1, wxDefaultPosition,
    # 					wxDefaultSize, wxDefaultPosition,
    # 					"mainPanel");
    $self->{filesNotebookSizer} = Wx::BoxSizer->new(wxVERTICAL);

    $self->{textCtrlPaneSizer1} = Wx::BoxSizer->new(wxVERTICAL);
    $self->{textCtrlPaneSizer2} = Wx::BoxSizer->new(wxVERTICAL);
    $self->{textCtrlPaneSizer3} = Wx::BoxSizer->new(wxVERTICAL);


    $self->{textCtrlPane1} = Wx::Panel->new($self->{filesPanel}, -1,
					    wxDefaultPosition, wxDefaultSize,
					    wxEXPAND, "textCtrlPanel1");
    $self->{textCtrlPane2} = Wx::Panel->new($self, -1,
					    wxDefaultPosition, wxDefaultSize,
					    wxEXPAND, "textCtrlPane2");
    $self->{textCtrlPane3} = Wx::Panel->new($self, -1,
					    wxDefaultPosition, wxDefaultSize,
					    wxEXPAND, "textCtrlPane3");


    # Test widgets
    $self->{textCtrl1} = Wx::TextCtrl->new($self->{textCtrlPane1}, -1, "Text 1",
    					   wxDefaultPosition, wxDefaultSize,
    					   wxNO_BORDER | wxTE_MULTILINE);
    $self->{textCtrl2} = Wx::TextCtrl->new($self->{textCtrlPane2}, -1, "Text 2",
    					   wxDefaultPosition, wxDefaultSize,
    					   wxNO_BORDER | wxTE_MULTILINE);
    $self->{textCtrl3} = Wx::TextCtrl->new($self->{textCtrlPane3}, -1, "Text 3",
    					   wxDefaultPosition, wxDefaultSize,
    					   wxNO_BORDER | wxTE_MULTILINE);

    $self->{saveButton} = Wx::Button->new($self->{textCtrlPane1}, -1, "&Save",
					  wxDefaultPosition, wxDefaultSize, 0,
					  wxDefaultValidator, "saveButton");

    # organizerTree has to be added before the first EditorPage gets added
    $self->{organizerTree} = Wx::TreeCtrl->new($self->{textCtrlPane3}, -1,
					       wxDefaultPosition,
					       wxDefaultSize, wxTR_HAS_BUTTONS,
					       wxDefaultValidator,
					       "organizerTree");

    $self->populateOrganizerTree();

    $self->addEditorGrid(GRID_TEST_FILE1, GRID_TEST_FILE1);
    $self->addEditorPage(INPUT_FILE1, INPUT_FILE1);
    $self->addEditorPage(INPUT_FILE2, INPUT_FILE2);
    $self->addEditorPage(INPUT_FILE3, INPUT_FILE3);


    $self->{directoryTree} = Wx::GenericDirCtrl->new($self->{textCtrlPane3}, -1,
						     # wxDirDialogDefaultFolderStr,
						     "/home",
						     wxDefaultPosition,
						     wxDefaultSize,
						     wxDIRCTRL_3D_INTERNAL |
						     wxSUNKEN_BORDER,
						     "", 0,
						     "directoryTree");


    # $self->{auiManager}->Update();
    # $self->{auiManager}->UnInit();

    $self->setProperties();
    $self->doLayout();
    $self->addEvents();
    $self->{auiManager}->Update();
    $self->{notebookManager}->Update();

    return $self;
}

sub setProperties {
    my  $self = shift;

    # Input panel
    $self->{textCtrl1}->SetBackgroundColour(Wx::Colour->new(0, 0, 0));
    $self->{textCtrl1}->SetForegroundColour(Wx::Colour->new(255, 255, 255));

    # Logging panel
    $self->{textCtrl2}->SetBackgroundColour(Wx::Colour->new(50, 0, 0));
    $self->{textCtrl2}->SetForegroundColour(Wx::Colour->new(255, 255, 255));

    $self->{textCtrl1}->LoadFile(INPUT_FILE1, wxTEXT_TYPE_ANY);

    $self->{textCtrl2}->SetEditable(0);
    $self->{textCtrl2}->SetInsertionPointEnd();
    $self->{textCtrl2}->LoadFile(LOG_FILE, wxTEXT_TYPE_ANY);

    $self->{statusBar}->SetFieldsCount(SB_FIELDS);
    # $self->{statusBar}->SetStatusWidths([-2, -1, 100]);
    $self->{statusBar}->SetStatusStyles(SB_FIELDS, [wxSB_NORMAL, wxSB_FLAT,
						    wxSB_RAISED]);

    # $self->{menuBar}->SetBackgroundColour(Wx::Colour->new(0, 100, 200,));
}

sub doLayout {
    my $self = shift;

    $self->Maximize($self);

    $self->{colorMenu}->Append(wxID_ANY, "Red", "Color: red",wxITEM_NORMAL);
    $self->{colorMenu}->Append(wxID_ANY, "Green", "Color: green",
			       wxITEM_NORMAL);
    $self->{colorMenu}->Append(wxID_ANY, "Blue", "Color: blue", wxITEM_NORMAL);

    $self->{fileMenu}->Append(wxID_OPEN, "&Open\tCTRL+o", "Opens a file",
			      wxITEM_NORMAL);
    $self->{fileMenu}->Append(wxID_SAVE, "&Save\tCTRL+s", "Saves the current file",
			      wxITEM_NORMAL);
    $self->{fileMenu}->AppendSubMenu($self->{colorMenu}, "&Colors",
				     "List of colors");
    $self->{fileMenu}->AppendSeparator();
    $self->{fileMenu}->Append(wxID_EXIT, "&Quit\tCTRL+q", "Quits the application",
			      wxITEM_NORMAL);
    # $self->{fileMenu}->Append(0, "&Save");
    $self->{menuBar}->Append($self->{fileMenu}, "&File");
    $self->SetMenuBar($self->{menuBar});
    $self->SetStatusBar($self->{statusBar});

    $self->{filesNotebookSizer}->Add($self->{filesNotebook}, 1,
    				     wxEXPAND, 0);

    $self->{textCtrlPaneSizer1}->Add($self->{textCtrl1}, 1,
    				     wxEXPAND, 0);
    $self->{textCtrlPaneSizer1}->Add($self->{saveButton}, 0,
				     wxEXPAND, 0);
    # Add the tree structure
    $self->{textCtrlPaneSizer2}->Add($self->{textCtrl2}, 1,
				     wxEXPAND, 0);
    $self->{textCtrlPaneSizer3}->Add($self->{textCtrl3}, 1,
				     wxEXPAND, 0);
    $self->{textCtrlPaneSizer3}->Add($self->{organizerTree}, 1,
				     wxEXPAND, 0);
    # $self->{textCtrlPaneSizer3}->Add($self->{directoryTree}, 1,
    # 				     wxEXPAND, 0);

    # $self->{auiManager}->AddPane($self->{textCtrlPane1}, wxCENTRE, "Panel #1");
    $self->{auiManager}->AddPane($self->{filesPanel}, wxCENTRE, "Panel #1");
    $self->{auiManager}->AddPane($self->{textCtrlPane2}, wxBOTTOM, "Panel #2");
    $self->{auiManager}->AddPane($self->{textCtrlPane3}, wxLEFT, "Panel #3");
    # $self->{auiManager}->AddPane($self->{mainPanel}, wxLEFT, "Panel #4");

    $self->{auiManager}->Update();

    # $self->{auiManager}->GetPane($self->{textCtrlPane1})->BestSize([150, 150]);
    $self->{auiManager}->GetPane($self->{filesPanel})->BestSize([150, 150]);
    # $self->{auiManager}->GetPane($self->{textCtrlPane1})->FloatingSize([300, 350]);
    $self->{auiManager}->GetPane($self->{textCtrlPane2})->BestSize([150, 150]);
    $self->{auiManager}->GetPane($self->{textCtrlPane3})->BestSize([150, 150]);

    # $self->{auiManager}->GetPane($self->{textCtrlPane1})->Row(2)->Left();
    $self->{auiManager}->GetPane($self->{filesPanel})->Row(2)->Left();
    $self->{auiManager}->GetPane($self->{textCtrlPane2})->Row(2)->Left();
    $self->{auiManager}->GetPane($self->{textCtrlPane3})->Row(1)->Top();

    $self->{auiManager}->GetPane($self->{textCtrlPane2})->MinSize([100, 150]);
    $self->{auiManager}->GetPane($self->{textCtrlPane3})->MinSize([200, 50]);

    # $self->{auiManager}->GetPane($self->{mainPanel})->Dockable();
    # $self->{auiManager}->GetPane($self->{textCtrlPane1})->DefaultPane();

    # $self->{auiManager}->GetPane($self->{textCtrl1})->Floatable();
    # $self->{auiManager}->GetPane($self->{textCtrlPane1})->Float();

    # $self->{auiManager}->GetPane($self->{textCtrlPane3})->dock_proportion => 50;
    # $self->{auiManager}->SetDockSizeConstraint(0.5, 0.5);

    $self->{filesPanel}->SetSizer($self->{filesNotebookSizer});

    $self->{textCtrlPane1}->SetSizer($self->{textCtrlPaneSizer1});
    $self->{textCtrlPane2}->SetSizer($self->{textCtrlPaneSizer2});
    $self->{textCtrlPane3}->SetSizer($self->{textCtrlPaneSizer3});

    $self->{statusBar}->SetStatusText(INPUT_FILE1, 1);

    $self->{textCtrl1}->SetFocus();

    $self->{filesNotebook}->AddPage($self->{textCtrlPane1}, INPUT_FILE1, 0,
				    wxNullBitmap);

    # TODO: BEGIN_REMOVE!
    my $testButton1 = Wx::Button->new($self->{textCtrlPane1}, -1, "&Save",
				      wxDefaultPosition, wxDefaultSize, 0,
				      wxDefaultValidator, "saveButton");
    $testButton1->SetBackgroundColour(Wx::Colour->new(255, 0, 0));
    $self->{filesNotebook}->AddPage($testButton1, INPUT_FILE1, 0,
				    wxNullBitmap);

    my $testButton2 = Wx::Button->new($self->{textCtrlPane1}, -1, "&Save",
				      wxDefaultPosition, wxDefaultSize, 0,
				      wxDefaultValidator, "saveButton");
    $testButton2->SetBackgroundColour(Wx::Colour->new(0, 255, 0));
    $self->{filesNotebook}->AddPage($testButton2, INPUT_FILE1, 0,
				    wxNullBitmap);

    my $testButton3 = Wx::Button->new($self->{textCtrlPane1}, -1, "&Save",
				      wxDefaultPosition, wxDefaultSize, 0,
				      wxDefaultValidator, "saveButton");
    $testButton3->SetBackgroundColour(Wx::Colour->new(0, 0, 255));
    $self->{filesNotebook}->AddPage($testButton3, INPUT_FILE1, 0,
				    wxNullBitmap);
    # TODO: END_REMOVE!

    $self->{organizerTree}->SetBackgroundColour(Wx::Colour->new(0, 255, 255));
}

sub addEvents {
    my $self = shift;

    Wx::Event::EVT_BUTTON($self->{saveButton}, -1, sub {
	my ($button, $event) = @_;


	$button->SetBackgroundColour(Wx::Colour->new(0, 255, 0));
	# Logging
	$self->{textCtrl2}->SetInsertionPointEnd();
	$self->{textCtrl2}->WriteText("\nFile \"" . INPUT_FILE1 .
				      "\" has been saved.");
	$self->{textCtrl2}->SaveFile(LOG_FILE, wxTEXT_TYPE_ANY);
	Wx::MessageBox("Content has been saved to file \"" . INPUT_FILE1 . "\".",
		       "Info", wxOK, $self->{textCtrlPane1});
	$button->SetBackgroundColour(wxLIGHT_GREY);

	# Saving
	$self->{textCtrl1}->SaveFile(INPUT_FILE1, wxTEXT_TYPE_ANY);
	$self->{textCtrlPane1}->SetFocus();
	$self->{textCtrl1}->SetFocus();
			  });

    Wx::Event::EVT_MENU($self, wxID_OPEN, sub {
	# Wx::MessageBox("Opening a file...", "Open", wxOK, $self);

	my $modal = $self->{fileDialog}->ShowModal();
	if ($modal != wxID_CANCEL) {
	    my $filename = $self->{fileDialog}->GetFilename();
	    my $path = $self->{fileDialog}->GetPath();
	    $self->addEditorPage($filename, $path);
	}
			});

    Wx::Event::EVT_MENU($self, wxID_SAVE, sub {
	# wxAuiNotebook Page <- wxPanel <- wxBoxSizer <- wxTextCtrl
	my $page = $self->{filesNotebook}->GetSelection();
	my $filename = $self->{filesNotebook}->GetPageText($page);
	my $childWindow = $self->{filesNotebook}->FindWindow($filename);

	$self->{statusBar}->SetStatusText("Saving file \"" . $filename .
					  "\"...", 1);

	# TODO: Continue here!
	if (ref($childWindow) eq "Wx::TextCtrl") {
	    $childWindow->SaveFile($filename, wxTEXT_TYPE_ANY);
	} elsif (ref($childWindow) eq "Wx::Grid") {
	    # Wx::MessageBox("Grid found!", "Info", wxOK, $self);
	    $childWindow->SelectAll();
	} else {
	    Wx::MessageBox("No window of type " . ref($childWindow) . " be found",
			   "Info", $self);
	}
	$self->{statusBar}->SetStatusText("---", 1);
			});

    # Quit the application
    Wx::Event::EVT_MENU($self, wxID_EXIT, sub{
	$self->{menuBar}->SetBackgroundColour(Wx::Colour->new(255, 0, 0,));
	$self->{statusBar}->SetBackgroundColour(Wx::Colour->new(255, 0, 0));
	my $msgBox = Wx::MessageBox("Do you really want to quit?", "Quit",
				    wxYES_NO,
				    $self);
      	$self->close() if $msgBox == wxYES;
	$self->{menuBar}->SetBackgroundColour(wxLIGHT_GREY);
	$self->{statusBar}->SetBackgroundColour(wxLIGHT_GREY);
			});

    # Tree events
    Wx::Event::EVT_TREE_BEGIN_DRAG($self, $self->{organizerTree}, sub {
	Wx::MessageBox("Dragging...", "Drag event", wxOK, $self);
				   });

    Wx::Event::EVT_TREE_ITEM_ACTIVATED($self, $self->{organizerTree}, sub {
	Wx::MessageBox("Tree item has been double clicked.", "Double click",
		       wxOK, $self);
				       });

    Wx::Event::EVT_TREE_ITEM_MENU($self, $self->{organizerTree}, sub {
	my ($item, $event) = @_;

	my $treeItemContextMenu = Wx::Menu->new();
	my $point = Wx::Point->new();
	$point = $event->GetPoint();
	my @item = $self->{organizerTree}->HitTest($point);
	$self->{itemText} = $self->{organizerTree}->GetItemText($item[0]);
	# for (my $i = 0; $i < 50; $i++) {
	#     $treeItemContextMenu->Append(wxID_OPEN,
	# 				 "&" .$self->{itemText}, "Tree item info",
	# 				 wxITEM_NORMAL);
	# }
	$treeItemContextMenu->Append(SET_BG_COLOR_ID,
				     "&Background color",
				     "Set background color",
				     wxITEM_NORMAL);

	$self->{organizerTree}->PopupMenu($treeItemContextMenu, $point);
				  });

    # EXPERIMENTAL
    # Possible solutin (?): override
    # wxAuiNotebook::OnTabClicked(wxCommandEvent& command_evt)
    # in a custom wxAuiNotebook class
    # Wx::Event::EVT_AUINOTEBOOK_GHANGED($self, $self->{filesNotebook}, sub {
    # 	my ($item, $event) = @_;

    # 	# Wx::MessageBox("Working...", "Info", wxOK, $self);

    # 	# $self->{filesNotebook}->ShowWindowMenu();
    # 	$self->{filesNotebook}->OnTabClicked();

    # 	# my $treeItemContextMenu = Wx::Menu->new();
    # 	# my $point = Wx::Point->new();
    # 	# $point = $event->GetPoint();
    # 	# my @item = $self->{filesNotebook}->HitTest($point);
    # 	# $treeItemContextMenu->Append(SET_BG_COLOR_ID,
    # 	# 			     "&Background color",
    # 	# 			     "Set background color",
    # 	# 			     wxITEM_NORMAL);

    # 	# $self->{filesNotebook}->PopupMenu($treeItemContextMenu, $point);
    # 				  });

    Wx::Event::EVT_AUINOTEBOOK_PAGE_CLOSE($self, $self->{filesNotebook}, sub {
	my $page = $self->{filesNotebook}->GetSelection();
	my $filename = $self->{filesNotebook}->GetPageText($page);

	my $rootItem = $self->{organizerTree}->GetRootItem();
	my @filesItem = $self->{organizerTree}->GetFirstChild($rootItem);
	my $n = $self->{organizerTree}->GetChildrenCount($filesItem[0], 0);
	# wxPerl's GetFirstChild(...) returns a list (item, cookie)!
	my @itemAndCookie = $self->{organizerTree}->GetFirstChild($filesItem[0]);
	my $item = $itemAndCookie[0];

	for (my $i = 0; $i < $n; $i++) {
	    if ($self->{organizerTree}->GetItemText($item) eq $filename) {
	    	$self->{organizerTree}->Delete($item);
	    }
	    $item = $self->{organizerTree}->GetNextSibling($item);
	}
					  });

    Wx::Event::EVT_MENU($self, SET_BG_COLOR_ID, sub {
	# Wx::MessageBox("Setting background color...", "Info", wxOK, $self);
	my $page;
	my $pageIndex;
	my $pageText;
	my $textCtrl;
	my $colourDialog;
	my $colour;

	for (my $i = 0; $i < $self->{filesNotebook}->GetPageCount(); $i++) {
	    $page = $self->{filesNotebook}->GetPage($i);
	    $pageIndex = $self->{filesNotebook}->GetPageIndex($page);
	    $pageText = $self->{filesNotebook}->GetPageText($pageIndex);
	    $textCtrl = $self->{filesNotebook}->FindWindow($pageText);
	    if ($pageText eq $self->{itemText}) {
		$colourDialog = Wx::ColourDialog->new($self,
						      Wx::ColourData->new());
		$colourDialog->ShowModal();
		$colour = $colourDialog->GetColourData()->GetColour();
		$textCtrl->SetBackgroundColour($colour);
	    }
	}
			});
}

sub close {
    my $self = shift;
    Wx::Window::Close($self);
}

sub populateOrganizerTree {
    my $self = shift;

    $self->{organizerTree}->AddRoot("IDE", -1, -1, Wx::TreeItemData->new());
    # Files
    $self->{organizerTree}->AppendItem($self->{organizerTree}->GetRootItem(),
				       "Files", -1, -1,
				       Wx::TreeItemData->new());
    my $rootItem = $self->{organizerTree}->GetRootItem();
    my @firstChild = $self->{organizerTree}->GetFirstChild($rootItem);
    $self->{organizerTree}->AppendItem(
	$firstChild[0],
    	INPUT_FILE1, -1, -1, Wx::TreeItemData->new());
    # $self->{organizerTree}->AppendItem(
    # 	$self->{organizerTree}->GetRootItem()->GetFirstChild()->GetLastChild(),
    # 	"Something", -1, -1, Wx::TreeItemData->new());

    # # Windows
    $self->{organizerTree}->AppendItem($self->{organizerTree}->GetRootItem(),
    				       "Windows", -1, -1,
    				       Wx::TreeItemData->new());
    # $self->{organizerTree}->AppendItem(
    # 	$self->{organizerTree}->GetRootItem()->GetLastChild(),
    # 	"Window 1", -1, -1,
    # 	Wx::TreeItemData->new());
    # $self->{organizerTree}->AppendItem(
    # $self->{organizerTree}->GetRootItem()->GetLastChild(),
    # 	"Window 2", -1, -1, Wx::TreeItemData->new());

    $self->{organizerTree}->SetItemBackgroundColour($firstChild[0],
						    Wx::Colour->new(255, 0, 0));
    $self->{organizerTree}->SetItemTextColour($firstChild[0],
					      Wx::Colour->new(255, 255, 255));
    $self->{organizerTree}->ExpandAll();
}

sub DESTROY {
    my $self = shift;
    $self->{auiManager}->UnInit();
    $self->{notebookManager}->UnInit();
}

sub makeTextCtrl {
    my ($self, $parent, $title) = @_;
    return Wx::TextCtrl->new( $parent, -1, $title,
			      wxDefaultPosition, wxDefaultSize, wxNO_BORDER |
			      wxTE_MULTILINE );
}

sub makeTextCtrlPanel {
    my ($self, $parent) = @_;
    return Wx::Panel->new( $parent, -1, wxDefaultPosition,
			   wxDefaultSize, wxEXPAND, "textCtrlPanel" );
}

sub addEditorPageOrig {
    my $self = shift;
    # Panel <- BoxSizer <- Panel <- TextCtrl

    # $self->{filesPanel} = Wx::Panel->new( $self, -1, wxDefaultPosition,
    # 					  wxDefaultSize, wxEXPAND,
    # 					  "filesPanel");

    # $self->{textCtrlPane1} = Wx::Panel->new( $self->{filesPanel}, -1,
    # 					     wxDefaultPosition, wxDefaultSize,
    # 					     wxEXPAND, "textCtrlPanel1" );

    # $self->{textCtrl1} = Wx::TextCtrl->new( $self->{textCtrlPane1}, -1, "Text 1",
    # 					    wxDefaultPosition, wxDefaultSize,
    # 					    wxNO_BORDER | wxTE_MULTILINE );


    # $self->{textCtrlPaneSizer1} = Wx::BoxSizer->new( wxVERTICAL );

    # $self->{textCtrlPane1}->SetSizer( $self->{textCtrlPaneSizer1} );


    # $self->{filesNotebook}->AddPage( $self->{textCtrlPane1}, INPUT_FILE1, 0,
    # 				     wxNullBitmap );

    # $self->{textCtrlPane1}->SetFocus();

    $self->{filesNotebook}->AddPage( makeTextCtrlPanel(
    					 makeTextCtrl( makeTextCtrlPanel,
    						       "Something" ) )->SetSizer(
    					 Wx::BoxSizer->new( wxVERTICAL )),
    				     INPUT_FILE1, 0, wxNullBitmap );
}

sub addEditorPage {
    # Notebook Page <- Panel <- BoxSizer <- TextCtrl
    my ($self, $title, $file) = @_;

    my $textCtrlPane = Wx::Panel->new( $self->{filesPanel}, -1,
				       wxDefaultPosition, wxDefaultSize,
				       wxEXPAND, "textCtrlPane" );

    # Custom ID to make it searchable for saving operations
    my $textCtrl = Wx::TextCtrl->new( $textCtrlPane, -101, "Default text",
				      wxDefaultPosition, wxDefaultSize,
				      wxNO_BORDER | wxTE_MULTILINE,
				      wxDefaultValidator, $title);

    $textCtrl->LoadFile($file, wxTEXT_TYPE_ANY);
    my $textCtrlPaneSizer = Wx::BoxSizer->new( wxVERTICAL );
    $textCtrlPaneSizer->Add( $textCtrl, 1, wxEXPAND, 0 );
    $textCtrlPane->SetSizer( $textCtrlPaneSizer );
    $self->{filesNotebook}->AddPage( $textCtrlPane, $title, 0,
    				     wxNullBitmap );
    $textCtrlPane->SetFocus();

    # Update tree info structure
    my $rootItem = $self->{organizerTree}->GetRootItem();
    my @firstChild = $self->{organizerTree}->GetFirstChild($rootItem);
    $self->{organizerTree}->AppendItem(
    	$firstChild[0],
    	$title, -1, -1, Wx::TreeItemData->new());
}

sub addEditorGrid {
    # Notebook Page <- Panel <- BoxSizer <- wxGrid
    my ( $self, $title, $file ) = @_;

    my $gridPane = Wx::Panel->new( $self->{filesPanel}, -1,
				       wxDefaultPosition, wxDefaultSize,
				       wxEXPAND, "gridPane" );

    # Custom ID to make it searchable for saving operations
    # my $grid = Wx::Grid->new( $gridPane, -1, wxDefaultPosition, wxDefaultSize,
    # 			        wxWANTS_CHARS, $title );
    # FIX: Improve!
    # my $grid = CustomGrid->new( $gridPane, -1, wxDefaultPosition, wxDefaultSize,
    # 				wxWANTS_CHARS, $title );

    # Set grid properties
    # $grid->CreateGrid(100, 10);
    # $grid->SetRowSize( 0, 60 );
    # $grid->SetRowSize( 0, 120 );
    # $grid->SetCellValue( 0, 3, "This is read only" );
    # $grid->SetReadOnly( 0, 3 );
    # $grid->SetCellValue( 3, 3, "green on grey" );
    # $grid->SetCellTextColour( 3, 3, Wx::Colour->new(0, 255, 0) );
    # $grid->SetCellBackgroundColour( 3, 3, Wx::Colour->new(100, 100, 100) );
    # $grid->SetColFormatFloat( 5, 6, 2 );
    # $grid->SetCellValue( 0, 6, "3.1415" );
    # $grid->SetColLabelValue(0, "File" );
    # $grid->EnableGridLines(0);
    # $grid->AutoSize();

    # # $textCtrl->LoadFile($file, wxTEXT_TYPE_ANY);
    # my $gridPaneSizer = Wx::BoxSizer->new( wxVERTICAL );
    # $gridPaneSizer->Add( $grid, 1, wxEXPAND, 0 );
    # $gridPane->SetSizer( $gridPaneSizer );
    # $self->{filesNotebook}->AddPage( $gridPane, $title, 0,
    # 				     wxNullBitmap );
    # $gridPane->SetFocus();

    # # Update tree info structure (not for grids, background colour setting is
    # # different)
    # my $rootItem = $self->{organizerTree}->GetRootItem();
    # my @firstChild = $self->{organizerTree}->GetFirstChild($rootItem);
    # $self->{organizerTree}->AppendItem(
    # 	$firstChild[0],
    # 	$title, -1, -1, Wx::TreeItemData->new());
}

sub populateEditorGrid {
    my $self = shift;

    my $page;
    my $pageIndex;
    my $pageText;
    my $textCtrl;

    for (my $i = 0; $i < $self->{filesNotebook}->GetPageCount(); $i++) {
	$page = $self->{filesNotebook}->GetPage($i);
	$pageIndex = $self->{filesNotebook}->GetPageIndex($page);
	$pageText = $self->{filesNotebook}->GetPageText($pageIndex);
	$textCtrl = $self->{filesNotebook}->FindWindow($pageText);
    }
}

1;
