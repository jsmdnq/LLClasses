module FormBinding;

import core.runtime;
import core.sys.windows.windows;
import LLClasses;
import std.stdio;
import std.string;
import SimpleForm;

class cMainForm: form
{
	private
	{
		form fForm1, fForm2, fForm3;
		cPropBinder!uint fHSync, fWSync;
	}
	protected
	{
		final override void doUpdatePosition()
		{
			scope(failure){};
			super.doUpdatePosition();
			if(!fForm3) return;
			//
			fWSync.Change(Width);
			fHSync.Change(Height);
		}
	}
	public
	{
		this(HINSTANCE aInstance)
		{
			super(aInstance);
			
			fHSync = new cPropBinder!uint; 
			fWSync = new cPropBinder!uint;
			
			Caption = "Resize-Me".dup;
			fForm1 = new form(aInstance);
			fForm2 = new form(aInstance);
			fForm3 = new form(aInstance);
			
			fForm1.Caption = "Form1".dup;
			fForm2.Caption = "Form2".dup;
			fForm3.Caption = "Form3".dup;
			
			fWSync.AddBinding( uintprop(&fForm1.Width,&fForm1.Width) );
			fWSync.AddBinding( uintprop(&fForm2.Width,&fForm2.Width) );
			fWSync.AddBinding( uintprop(&fForm3.Width,&fForm3.Width) );
			
			fHSync.AddBinding( uintprop(&fForm1.Height,&fForm1.Height) );
			fHSync.AddBinding( uintprop(&fForm2.Height,&fForm2.Height) );
			fHSync.AddBinding( uintprop(&fForm3.Height,&fForm3.Height) );
			
			Top = 10;
			Left = 10;
			Width = 200;
			Height = 120;
			
			fForm1.Left = Left + Width + 100;
			fForm1.Top = Top;
			fForm2.Left = Left;
			fForm2.Top = Top + Height + 100;
			fForm3.Left = Left + Width + 100;
			fForm3.Top = Top + Height + 100;
		}
		~this()
		{
			delete fWSync;
			delete fHSync;
			delete fForm1;
			delete fForm2;
			delete fForm3;
		}
	}
}

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
	int result;
	void exceptionHandler(Throwable e) { throw e; }

	try
	{
		Runtime.initialize(&exceptionHandler);
		result = myWinMain(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
		Runtime.terminate(&exceptionHandler);
	}
	catch (Throwable e)
	{
		MessageBoxA(null, e.toString().toStringz, "E r r o r", MB_OK | MB_ICONEXCLAMATION);
		result = 0;
	}

	return result;
}
int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{	
	MSG  msg;

	cMainForm Form; 
	Form = new cMainForm(hInstance);

	while (GetMessageA(&msg, null, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessageA(&msg);
	}
	delete Form;
	return msg.wParam;
}

