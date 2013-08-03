module SimpleForm;

import core.runtime;
import core.sys.windows.windows;
import LLClasses;
import std.stdio;
pragma(lib, "gdi32.lib");
import std.string;

enum IDC_BTNCLICK     	= 101;
enum IDC_BTNDONTCLICK 	= 102;

enum SWP_SHOWWINDOW		= 0x0040;
enum WM_MOVING         = 0x0216;
enum SW_SHOW 			= 5;
enum WM_SIZING			= 0x0214;
enum SIZE_RESTORED		= 0;
enum SIZE_MINIMIZED		= 1;
enum SIZE_MAXIMIZED		= 2;
int GWLP_USERDATA		= -21;

extern(Windows)
{
	BOOL EnableWindow( HWND hWnd, BOOL bEnable) nothrow;
	
	BOOL SetWindowPos(
						HWND hWnd,
						HWND hWndInsertAfter,
						int X,
						int Y,
						int cx,
						int cy,
						UINT uFlags
							) nothrow;
	BOOL SetWindowTextA( HWND hWnd, LPCTSTR lpString) nothrow;

	LONG_PTR SetWindowLongW(HWND hWnd, int nIndex, LONG_PTR dwNewLong) nothrow;

	LONG_PTR GetWindowLongW(HWND hWnd, int nIndex) nothrow;

	void SetLastError(DWORD dwErrCode) nothrow; 

	struct CREATESTRUCT {
		LPVOID    lpCreateParams;
		HINSTANCE hInstance;
		HMENU     hMenu;
		HWND      hwndParent;
		int       cy;
		int       cx;
		int       y;
		int       x;
		LONG      style;
		LPCTSTR   lpszName;
		LPCTSTR   lpszClass;
		DWORD     dwExStyle;
	};
	alias CREATESTRUCT* LPCREATESTRUCT;
}

struct Rect{int Left,Top,Right,Bottom;}
const enum WindowState {wsMin=0,wsNorm=1,wsMax=2}

class form: cObjectEx
{
	private
	{
		HWND fHandle;
		HWND fWindowHandle;
		HWND fDeviceContext;
		WNDCLASSEXA fwndclass;
		Rect fClientRect;
		Rect fRect;
		uint fHeight;
		uint fWidth;
		uint fTop;
		uint fLeft;
		uint fState;
		char[] fExeName;
		char[] fCaption;
		bool fEnabled;
		HINSTANCE finstance;
		dNotification fOnCreate;
		dNotification fOnClose;
		dNotification fOnActivate, fOnDeactivate;
		dNotification fOnEnabled, fOnDisabled;
		dNotification fOnMaximized, fOnMinimized, fOnRestored;
		
		// setters updates
		void UpdatePosition() nothrow
		{
			if (!fHandle) return;
			SetWindowPos( fHandle, null, fLeft, fTop, fWidth, fHeight, SWP_SHOWWINDOW);
		}
		void UpdateState() nothrow
		{
			if (!fHandle) return;
			int[3] StateLUT = [SW_MINIMIZE,SW_SHOWNORMAL,SW_MAXIMIZE];
			ShowWindow( fHandle,StateLUT[fState]);
		}
		void UpdateCaption() nothrow
		{
			if (!fHandle) return;
			SetWindowTextA( fHandle, fCaption.toStringz);
		}
		void UpdateEnabled() nothrow
		{
			if (!fHandle) return;
			EnableWindow( fHandle, fEnabled);
		}

		void CreateWindow()
		{	
			string className =  this.classinfo.name ~ format("%.16x",cast(void*)this);
			fwndclass.cbSize		= WNDCLASSEXA.sizeof;
			fwndclass.style         = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
			fwndclass.lpfnWndProc   = &WindowProc;
			fwndclass.cbClsExtra    = 0;
			fwndclass.cbWndExtra    = 0;
			fwndclass.hInstance     = finstance;
			fwndclass.hIcon         = LoadIconA(null, IDI_APPLICATION);
			fwndclass.hCursor       = LoadCursorA(null, IDC_ARROW);
			fwndclass.hbrBackground = cast(HBRUSH)GetStockObject(COLOR_APPWORKSPACE);
			fwndclass.lpszMenuName  = null;
			fwndclass.lpszClassName = className.toStringz;
			fwndclass.hIconSm		= null;

			if (!RegisterClassExA(&fwndclass))
			{
				MessageBoxA(null, "Couldn't register Window Class!", fCaption.toStringz, MB_ICONERROR);
			}

			fHandle = CreateWindowExA(
								0,
								className.toStringz,	// window class name 
								fCaption.toStringz,		// window caption
								WS_THICKFRAME   |
								WS_MAXIMIZEBOX  |
								WS_MINIMIZEBOX  |
								WS_SYSMENU      |
								WS_VISIBLE,				// window style
								fLeft,					// initial x position
								fTop,					// initial y position
								fWidth,					// initial x size
								fHeight,				// initial y size
								HWND_DESKTOP,			// parent window handle
								null,					// window menu handle
								finstance,				// program instance handle
								cast(void*) this);		// creation parameters

			if (fHandle is null)
			{
				MessageBoxA(null, "Couldn't create window.", fCaption.toStringz, MB_ICONERROR);
			}

			
			ShowWindow(fHandle, SW_SHOW);
			UpdateWindow(fHandle);
			UpdatePosition;
		}
	}
	protected
	{
		// events virtual methods
		void doCreate() nothrow
		{
			if (fOnCreate) fOnCreate(this);
		}
		void doClose() nothrow
		{
			if (fOnClose) fOnClose(this);
		}
		void doActivate() nothrow
		{
			if (fOnActivate) fOnActivate(this);
		}
		void doDeactivate() nothrow
		{
			if (fOnDeactivate) fOnDeactivate(this);
		}
		void doEnabled() nothrow
		{
			fEnabled = true;
			if (fOnEnabled) fOnEnabled(this);
		}
		void doDisabled() nothrow
		{
			fEnabled = false;
			if (fOnDisabled) fOnDisabled(this);
		}
		void doMinimized() nothrow
		{
			fState = WindowState.wsMin;
			if (fOnMinimized) fOnMinimized(this);
		}
		void doMaximized() nothrow
		{
			fState = WindowState.wsMax;
			if (fOnMinimized) fOnMaximized(this);
		}
		void doRestored() nothrow
		{
			fState = WindowState.wsNorm;
			if (fOnRestored) fOnRestored(this);
		}
		void doUpdatePosition() nothrow
		{
		}
	}
	public
	{
		this(HINSTANCE aInstance)
		{
			finstance = aInstance;
			fHeight = 400;
			fWidth  = 600;
			fTop	= 10;
			fLeft	= 10;
			CreateWindow;
		}

		extern(Windows) static
		LRESULT WindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
		{	
			form lForm;
			if (message != WM_CREATE) 
			{
				lForm = cast(form) (cast(form*) GetWindowLongW(hWnd, GWLP_USERDATA));
				if(lForm) return lForm.VirtualWindowProc(hWnd,message,wParam,lParam);
				else return DefWindowProcA(hWnd, message, wParam, lParam);
			}
			else
			{
				auto lCreat = cast(LPCREATESTRUCT) lParam;
				lForm = cast(form) lCreat.lpCreateParams;
				SetLastError(0);
				auto lIsSet = SetWindowLongW(hWnd, GWLP_USERDATA, cast(LONG_PTR) (cast(void*)lForm));
				auto lNoErr = (GetLastError == 0);
				assert((lIsSet != 0) | (lNoErr));
				return 0;
			}
			return 0;	
		}

		LRESULT VirtualWindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
		{
			switch (message)
			{
				case WM_CREATE:
					fWindowHandle = hWnd;
					fDeviceContext = GetDC(hWnd);
					doCreate();
					break;
					
				case WM_ACTIVATEAPP:			
					if(wParam) doActivate(); else doDeactivate();
					break;
					
				case WM_ENABLE:
					if(wParam) doEnabled(); else doDisabled();
					break;
					
				case WM_SIZE:
					fClientRect.Right  = fClientRect.Left + LOWORD(lParam);
					fClientRect.Bottom = fClientRect.Top + HIWORD(lParam);
					if (wParam == SIZE_MAXIMIZED) doMaximized();
					else if (wParam == SIZE_MINIMIZED) doMinimized();
					else if (wParam == SIZE_RESTORED) doRestored();
					doUpdatePosition();
					break;
					
				case WM_MOVE:
					fClientRect.Left  = LOWORD(lParam);
					fClientRect.Right = HIWORD(lParam);
					break;
					
				case WM_MOVING, WM_SIZING:
					auto lRect = cast(RECT*) lParam;
					fLeft   = lRect.left;
					fTop    = lRect.top;
					fWidth  = lRect.right - lRect.left;
					fHeight = lRect.bottom - lRect.top;
					doUpdatePosition();
					return TRUE;
					
				case WM_DESTROY, WM_CLOSE:
					doClose();
					PostQuitMessage(0);
					break;
					
				default: 
					return DefWindowProcA(hWnd, message, wParam, lParam);
			}
			return 0;	
		}

		@property
		{
			// form props
			void Height(uint aValue) nothrow
			{
				if (fHeight == aValue) return;
				fHeight = aValue;
				UpdatePosition;
			}
			uint Height() nothrow {return fHeight;}
			void Width(uint aValue) nothrow
			{
				if (fWidth == aValue) return;
				fWidth = aValue;
				UpdatePosition;
			}
			uint Width() nothrow {return fWidth;}
			void Top(uint aValue) nothrow
			{
				if (fTop == aValue) return;
				fTop = aValue;
				UpdatePosition;
			}
			uint Top() nothrow {return fTop;}
			void Left(uint aValue) nothrow
			{
				if (fLeft == aValue) return;
				fLeft = aValue;
				UpdatePosition;
			}
			uint Left() nothrow {return fLeft;}
			void FormState(uint aValue) nothrow
			{
				if (fState == aValue) return;
				fState = aValue;
				UpdateState;
			}
			uint FormState() nothrow {return fState;}
			void Caption(char[] aValue) nothrow
			{
				if (fCaption == aValue) return;
				fCaption = aValue;
				UpdateCaption;
			}
			char[] Caption() nothrow {return fCaption;}
			void Enabled(bool aValue) nothrow
			{
				if(fEnabled == aValue) return;
				fEnabled = aValue;
				UpdateEnabled;
			}
			bool Enabled() nothrow {return fEnabled;}

			// events
			void OnCreate(dNotification aValue){fOnCreate = aValue;}
			dNotification OnCreate(){return fOnCreate;}
			void OnClose(dNotification aValue){fOnClose = aValue;}
			dNotification OnClose(){return fOnClose;}
			void OnActivate(dNotification aValue){fOnActivate = aValue;}
			dNotification OnActivate(){return fOnActivate;}
			void OnDeactivate(dNotification aValue){fOnDeactivate = aValue;}
			dNotification OnDeactivate(){return fOnDeactivate;}
			void OnEnabled(dNotification aValue){fOnEnabled = aValue;}
			dNotification OnEnabled(){return fOnEnabled;}
			void OnDisabled(dNotification aValue){fOnDisabled = aValue;}
			dNotification OnDisabled(){return fOnDisabled;}
			void OnMaximized(dNotification aValue){fOnMaximized = aValue;}
			dNotification OnMaximized(){return fOnMaximized;}
			void OnMinimized(dNotification aValue){fOnMinimized = aValue;}
			dNotification OnMinimized(){return fOnMinimized;}
			void OnRestored(dNotification aValue){fOnRestored = aValue;}
			dNotification OnRestored(){return fOnRestored;}

			// infos
			HWND Handle(){return fHandle;}
			HWND DeviceContext(){return fDeviceContext;}
			HWND WindowHandle(){return fWindowHandle;}
		}
		override void DeclareProperties(cMasterSerializer aSerializer)
		{
			super.DeclareProperties(aSerializer);

			aSerializer.AddProperty!uint(uintprop(&Height,&Height,"Height") );
			aSerializer.AddProperty!uint(uintprop(&Width,&Width,"Width") );
			aSerializer.AddProperty!uint(uintprop(&Top,&Top,"Top") );
			aSerializer.AddProperty!uint(uintprop(&Left,&Left,"Left"));
			aSerializer.AddProperty!uint(uintprop(&FormState,&FormState,"FormState"));
			aSerializer.AddProperty!(char[])(sPropDescriptor!(char[])(&Caption,&Caption,"Caption") );
		}
	}
}