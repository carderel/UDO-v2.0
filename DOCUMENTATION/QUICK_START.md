# Quick Start: Install & First Session (10 minutes)

Let's get UDO up and running in less than 10 minutes.

## Step 1: Install UDO (2 minutes)

Choose your platform:

### Mac / Linux

```bash
curl -fsSL https://github.com/carderel/UDO-No-Script-Complete/archive/refs/heads/main.zip -o udo.zip && \
unzip udo.zip && \
mv UDO-No-Script-Complete-main/UDO ./UDO && \
rm -rf udo.zip UDO-No-Script-Complete-main
```

**What this does:**
- Downloads latest UDO
- Extracts the `UDO/` folder to your project
- Cleans up temporary files

### Windows (PowerShell)

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://github.com/carderel/UDO-No-Script-Complete/archive/refs/heads/main.zip" -OutFile "udo.zip"
Expand-Archive -Path "udo.zip" -DestinationPath "."
Move-Item -Path "UDO-No-Script-Complete-main\UDO" -Destination ".\"
Remove-Item -Path "udo.zip", "UDO-No-Script-Complete-main" -Recurse
```

**Done!** You now have a `UDO/` folder in your project.

## Step 2: Start Your LLM (2 minutes)

Open your AI tool and navigate to your project folder:

```bash
cd /path/to/your/project
claude .          # Claude Code
# OR
cursor .          # Cursor
# OR
# Your other LLM's command to open the folder
```

**Important:** Your LLM must be run **from within the project folder** (the one containing `UDO/`) for proper context loading.

## Step 3: Begin First Session (6 minutes)

Tell your AI:

```
Read UDO/START_HERE.md and begin
```

The AI will:
1. Read the onboarding document
2. Check the project state
3. Ask you clarifying questions
4. Create an orientation report
5. Ask what you want to work on

**That's it!** You're now in a UDO session.

---

## After First Session

Your project now contains:

```
your-project/
├── UDO/                    # Framework (don't edit directly)
│   ├── START_HERE.md       # AI reads this at session start
│   ├── PROJECT_STATE.json  # Current goal and progress
│   ├── .project-catalog/   # Session logs and decisions
│   └── [other framework files]
├── DOCUMENTATION/          # You are here
│   ├── README.md
│   ├── QUICK_START.md      # This file
│   └── FOLDER_GUIDE.md
└── [your project files]
```

## Next Steps

**For next session:**
- Start your LLM from the project folder again
- Tell AI: `Resume` or `Deep resume`
- AI will load previous context and continue

**To understand the structure:**
- Read [FOLDER_GUIDE.md](FOLDER_GUIDE.md) to learn what each folder does

**To learn more:**
- Read [UDO/ORCHESTRATOR.md](../UDO/ORCHESTRATOR.md) for full protocol
- Read [UDO/HARD_STOPS.md](../UDO/HARD_STOPS.md) to understand constraints

## Troubleshooting

**"LLM doesn't see the UDO folder"**
- Make sure you ran the install command from the correct directory
- Check that `UDO/` folder exists: `ls -la UDO/` (Mac/Linux) or `dir UDO` (Windows)

**"I'm getting permission errors"**
- Make sure you have write access to the project folder
- Try running with appropriate permissions

**"What if I'm upgrading from an older version?"**
- See [FOLDER_GUIDE.md](FOLDER_GUIDE.md) under "Upgrading"

---

**Ready?** Start your LLM and tell it: `Read UDO/START_HERE.md and begin`
