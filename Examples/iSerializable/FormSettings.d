module FormSettings;

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
		form fSubForm;
	}
	public
	{
		this(HINSTANCE aInstance)
		{
			super(aInstance);
			//
			Caption = "MainForm".dup;
			fSubForm = new form(aInstance);
			fSubForm.Caption = "SubForm".dup;
			fSubForm.Left = Left + 50;
			fSubForm.Top = Top + 50;
			// read settings
			auto lStr = new cFileStream("form.settings.txt");
			if (lStr.Size > 0)
			{
				auto lSer = new cMasterSerializer(eSerializationKind.sktext);
				lSer.Deserialize(cast(iSerializable)this,lStr);
				delete lSer;
			}
			delete lStr;
		}
		~this()
		{
			auto lStr = new cMemoryStream;
			auto lSer = new cMasterSerializer(eSerializationKind.sktext);
			lSer.Serialize(cast(iSerializable)this,lStr);
			lStr.SaveToFile("form.settings.txt");
			delete lStr;
			delete lSer;
			delete fSubForm;
		}
		override void DeclareProperties(cMasterSerializer aSerializer)
		{
			super.DeclareProperties(aSerializer);
			auto PropO = objprop(cast(Object*)&fSubForm,"SubForm");
			aSerializer.AddProperty!Object(PropO);
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

