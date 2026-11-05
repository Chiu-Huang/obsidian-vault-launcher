using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

internal static class Launcher
{
    [DllImport("kernel32.dll", SetLastError = true)] private static extern bool AttachConsole(uint processId);
    [DllImport("kernel32.dll")] private static extern IntPtr GetStdHandle(int handle);
    [DllImport("kernel32.dll")] private static extern uint GetFileType(IntPtr handle);
    private static bool textOutput;
    private static void Report(string message, bool error)
    {
        if (textOutput) { if (error) Console.Error.WriteLine(message); else Console.WriteLine(message); }
        else MessageBox.Show(message, "Obsidian Vault Launcher", MessageBoxButtons.OK,
            error ? MessageBoxIcon.Error : MessageBoxIcon.Information);
    }
    private static string Literal(string value) { return "'" + value.Replace("'", "''") + "'"; }
    public static int Main(string[] args)
    {
        // Attach only to an existing terminal. Explorer launches never allocate one.
        bool redirected = GetFileType(GetStdHandle(-11)) != 0;
        textOutput = redirected || AttachConsole(unchecked((uint)-1));
        try
        {
            bool check = args.Length > 0 && args[0] == "--check";
            int offset = check ? 1 : 0;
            if (args.Length > offset + 1) throw new ArgumentException("Usage: ov [--check] [folder]");
            string folder = Path.GetFullPath(args.Length > offset ? args[offset] : ".");
            if (!Directory.Exists(folder)) throw new DirectoryNotFoundException(folder);
            if (check) { Report(folder, false); return 0; }
            string script = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ov-core.ps1");
            if (!File.Exists(script)) throw new FileNotFoundException("Missing ov-core.ps1", script);
            string command = "& " + Literal(script) + " -Folder " + Literal(folder) + "; exit $LASTEXITCODE";
            var info = new ProcessStartInfo(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell\\v1.0\\powershell.exe"),
                "-NoLogo -NoProfile -OutputFormat Text -ExecutionPolicy Bypass -EncodedCommand " + Convert.ToBase64String(Encoding.Unicode.GetBytes(command)));
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.WorkingDirectory = Environment.CurrentDirectory;
            using (var child = Process.Start(info))
            {
                var stdout = child.StandardOutput.ReadToEndAsync();
                var stderr = child.StandardError.ReadToEndAsync();
                child.WaitForExit();
                Task.WaitAll(stdout, stderr);
                string details = (stdout.Result + Environment.NewLine + stderr.Result).Trim();
                if (child.ExitCode != 0) Report(details.Length > 0 ? details : "Obsidian could not open this folder.", true);
                else if (textOutput && details.Length > 0) Report(details, false);
                return child.ExitCode;
            }
        }
        catch (Exception ex) { Report("ov: " + ex.Message, true); return 1; }
    }
}
