using System;
using System.Diagnostics;
using System.IO;
using System.Text;

internal static class Launcher
{
    private static string Literal(string value) { return "'" + value.Replace("'", "''") + "'"; }
    public static int Main(string[] args)
    {
        try
        {
            bool check = args.Length > 0 && args[0] == "--check";
            int offset = check ? 1 : 0;
            if (args.Length > offset + 1) throw new ArgumentException("Usage: ov [--check] [folder]");
            string folder = Path.GetFullPath(args.Length > offset ? args[offset] : ".");
            if (!Directory.Exists(folder)) throw new DirectoryNotFoundException(folder);
            if (check) { Console.WriteLine(folder); return 0; }
            string script = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ov-core.ps1");
            if (!File.Exists(script)) throw new FileNotFoundException("Missing ov-core.ps1", script);
            string command = "& " + Literal(script) + " -Folder " + Literal(folder) + "; exit $LASTEXITCODE";
            var info = new ProcessStartInfo(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell\\v1.0\\powershell.exe"),
                "-NoLogo -NoProfile -OutputFormat Text -ExecutionPolicy Bypass -EncodedCommand " + Convert.ToBase64String(Encoding.Unicode.GetBytes(command)));
            info.UseShellExecute = false;
            info.WorkingDirectory = Environment.CurrentDirectory;
            using (var child = Process.Start(info)) { child.WaitForExit(); return child.ExitCode; }
        }
        catch (Exception ex) { Console.Error.WriteLine("ov: " + ex.Message); return 1; }
    }
}
