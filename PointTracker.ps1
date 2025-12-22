# PRIME Score Tracker - WORKING VERSION (Old Selection + New Notes)
# Calendar dates select with white border highlight, notes change/load/save correctly

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$dataFile = "C:\Users\PRIME\Downloads\Coding\Vibe\Point Tracker\prime_score.json"

# Load existing data safely
$script:data = @()
if (Test-Path $dataFile) {
    try {
        $content = Get-Content $dataFile -Raw -ErrorAction Stop
        if (![string]::IsNullOrWhiteSpace($content)) {
            $loaded = $content | ConvertFrom-Json -ErrorAction Stop
            $script:data = $loaded | Where-Object { $_.Date -and $_.Category -match '^(Note|Writing)$' }
        }
    } catch {
        $script:data = @()
    }
}

$script:displayMonth = Get-Date
$script:selectedDate = Get-Date

# Save note for current selected date
function Save-CurrentNote {
    $dateStr = $script:selectedDate.ToString("yyyy-MM-dd")
    $noteText = $notesTextBox.Text.Trim()

    $script:data = $script:data | Where-Object { -not ($_.Date -eq $dateStr -and $_.Category -eq "Note") }

    if ($noteText) {
        $script:data += [PSCustomObject]@{
            Date     = $dateStr
            Category = "Note"
            Points   = 0
            Note     = $noteText
        }
    }

    $script:data | ConvertTo-Json -Depth 10 | Set-Content $dataFile -Force
}

# Load note for currently selected date
function LoadNoteForSelectedDate {
    $dateStr = $script:selectedDate.ToString("yyyy-MM-dd")
    $selectedDateLabel.Text = $script:selectedDate.ToString("dddd, MMMM d, yyyy")
    $notesTextBox.Text = ""

    $note = $script:data | Where-Object { $_.Date -eq $dateStr -and $_.Category -eq "Note" } | Select-Object -First 1
    if ($note) { $notesTextBox.Text = $note.Note }
}

# Rounded corners
function Set-RoundedCorners($control, $radius = 20) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rect = $control.ClientRectangle
    $rect.Width -= 1
    $rect.Height -= 1
    $path.AddArc($rect.X, $rect.Y, $radius, $radius, 180, 90)
    $path.AddArc($rect.Right - $radius, $rect.Y, $radius, $radius, 270, 90)
    $path.AddArc($rect.Right - $radius, $rect.Bottom - $radius, $radius, $radius, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $radius, $radius, $radius, 90, 90)
    $path.CloseFigure()
    $control.Region = New-Object System.Drawing.Region($path)
}

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PRIME Score Tracker"
$form.Size = New-Object System.Drawing.Size(1280, 820)
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
$form.StartPosition = "CenterScreen"

$form.Add_FormClosing({ Save-CurrentNote })

# Input Panel
$inputPanel = New-Object System.Windows.Forms.Panel
$inputPanel.Location = New-Object System.Drawing.Point(20, 20)
$inputPanel.Size = New-Object System.Drawing.Size(400, 200)
$inputPanel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 75)
$form.Controls.Add($inputPanel)
Set-RoundedCorners $inputPanel 15

$pointsLabel = New-Object System.Windows.Forms.Label
$pointsLabel.Text = "Points:"
$pointsLabel.ForeColor = [System.Drawing.Color]::White
$pointsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$pointsLabel.Location = New-Object System.Drawing.Point(10, 15)
$pointsLabel.Size = New-Object System.Drawing.Size(80, 25)
$inputPanel.Controls.Add($pointsLabel)

$pointsBox = New-Object System.Windows.Forms.TextBox
$pointsBox.Location = New-Object System.Drawing.Point(100, 12)
$pointsBox.Size = New-Object System.Drawing.Size(120, 28)
$pointsBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$pointsBox.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 100)
$pointsBox.ForeColor = [System.Drawing.Color]::White
$pointsBox.Text = ""
$inputPanel.Controls.Add($pointsBox)

$increasePointsBtn = New-Object System.Windows.Forms.Button
$increasePointsBtn.Text = "+0.5"
$increasePointsBtn.Location = New-Object System.Drawing.Point(225, 12)
$increasePointsBtn.Size = New-Object System.Drawing.Size(50, 28)
$increasePointsBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 100)
$increasePointsBtn.ForeColor = [System.Drawing.Color]::White
$increasePointsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$increasePointsBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$increasePointsBtn.FlatAppearance.BorderSize = 0
$increasePointsBtn.Add_Click({
    try {
        $current = if ([string]::IsNullOrWhiteSpace($pointsBox.Text)) { 0 } else { [decimal]$pointsBox.Text }
        $pointsBox.Text = [string]($current + 0.5)
    } catch {
        $pointsBox.Text = "0.5"
    }
})
$inputPanel.Controls.Add($increasePointsBtn)
Set-RoundedCorners $increasePointsBtn 10

$decreasePointsBtn = New-Object System.Windows.Forms.Button
$decreasePointsBtn.Text = "-0.5"
$decreasePointsBtn.Location = New-Object System.Drawing.Point(280, 12)
$decreasePointsBtn.Size = New-Object System.Drawing.Size(50, 28)
$decreasePointsBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 50, 50)
$decreasePointsBtn.ForeColor = [System.Drawing.Color]::White
$decreasePointsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$decreasePointsBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$decreasePointsBtn.FlatAppearance.BorderSize = 0
$decreasePointsBtn.Add_Click({
    try {
        $current = if ([string]::IsNullOrWhiteSpace($pointsBox.Text)) { 0 } else { [decimal]$pointsBox.Text }
        $pointsBox.Text = [string]($current - 0.5)
    } catch {
        $pointsBox.Text = "-0.5"
    }
})
$inputPanel.Controls.Add($decreasePointsBtn)
Set-RoundedCorners $decreasePointsBtn 10

$dateLabel = New-Object System.Windows.Forms.Label
$dateLabel.Text = "Date:"
$dateLabel.ForeColor = [System.Drawing.Color]::White
$dateLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$dateLabel.Location = New-Object System.Drawing.Point(10, 55)
$dateLabel.Size = New-Object System.Drawing.Size(80, 25)
$inputPanel.Controls.Add($dateLabel)

$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = New-Object System.Drawing.Point(100, 52)
$datePicker.Size = New-Object System.Drawing.Size(280, 28)
$datePicker.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$datePicker.Value = $script:selectedDate
$inputPanel.Controls.Add($datePicker)

$addBtn = New-Object System.Windows.Forms.Button
$addBtn.Text = "Add"
$addBtn.Location = New-Object System.Drawing.Point(10, 100)
$addBtn.Size = New-Object System.Drawing.Size(180, 50)
$addBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
$addBtn.ForeColor = [System.Drawing.Color]::White
$addBtn.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$addBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$addBtn.FlatAppearance.BorderSize = 0
$addBtn.Add_Click({
    try {
        if ([string]::IsNullOrWhiteSpace($pointsBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a number", "Invalid Input", "OK", "Warning")
            return
        }
        $pointsValue = [decimal]$pointsBox.Text
        $entry = [PSCustomObject]@{
            Date     = $script:selectedDate.ToString("yyyy-MM-dd")
            Category = "Writing"
            Points   = $pointsValue
        }
        $script:data += $entry
        UpdateCalendar
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid number", "Invalid Input", "OK", "Warning")
    }
})
$inputPanel.Controls.Add($addBtn)
Set-RoundedCorners $addBtn 15

$removeBtn = New-Object System.Windows.Forms.Button
$removeBtn.Text = "Remove"
$removeBtn.Location = New-Object System.Drawing.Point(200, 100)
$removeBtn.Size = New-Object System.Drawing.Size(180, 50)
$removeBtn.BackColor = [System.Drawing.Color]::FromArgb(220, 50, 50)
$removeBtn.ForeColor = [System.Drawing.Color]::White
$removeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$removeBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$removeBtn.FlatAppearance.BorderSize = 0
$removeBtn.Add_Click({
    try {
        if ([string]::IsNullOrWhiteSpace($pointsBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a number", "Invalid Input", "OK", "Warning")
            return
        }
        $pointsValue = [decimal]$pointsBox.Text
        $entry = [PSCustomObject]@{
            Date     = $script:selectedDate.ToString("yyyy-MM-dd")
            Category = "Writing"
            Points   = -$pointsValue
        }
        $script:data += $entry
        UpdateCalendar
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid number", "Invalid Input", "OK", "Warning")
    }
})
$inputPanel.Controls.Add($removeBtn)
Set-RoundedCorners $removeBtn 15

# Today's Total Panel
$todayPanel = New-Object System.Windows.Forms.Panel
$todayPanel.Location = New-Object System.Drawing.Point(20, 240)
$todayPanel.Size = New-Object System.Drawing.Size(400, 100)
$todayPanel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 75)
$form.Controls.Add($todayPanel)
Set-RoundedCorners $todayPanel 15

$todayTitleLabel = New-Object System.Windows.Forms.Label
$todayTitleLabel.Text = "TODAY'S TOTAL"
$todayTitleLabel.ForeColor = [System.Drawing.Color]::Gray
$todayTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$todayTitleLabel.Location = New-Object System.Drawing.Point(10, 10)
$todayTitleLabel.AutoSize = $true
$todayPanel.Controls.Add($todayTitleLabel)

$todayPointsLabel = New-Object System.Windows.Forms.Label
$todayPointsLabel.Text = "0 pts"
$todayPointsLabel.ForeColor = [System.Drawing.Color]::Cyan
$todayPointsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$todayPointsLabel.Location = New-Object System.Drawing.Point(10, 35)
$todayPointsLabel.AutoSize = $true
$todayPanel.Controls.Add($todayPointsLabel)

# Month Total Panel
$monthTotalPanel = New-Object System.Windows.Forms.Panel
$monthTotalPanel.Location = New-Object System.Drawing.Point(20, 360)
$monthTotalPanel.Size = New-Object System.Drawing.Size(400, 100)
$monthTotalPanel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 75)
$form.Controls.Add($monthTotalPanel)
Set-RoundedCorners $monthTotalPanel 15

$monthTotalTitleLabel = New-Object System.Windows.Forms.Label
$monthTotalTitleLabel.Text = "MONTH TOTAL"
$monthTotalTitleLabel.ForeColor = [System.Drawing.Color]::Gray
$monthTotalTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$monthTotalTitleLabel.Location = New-Object System.Drawing.Point(10, 10)
$monthTotalTitleLabel.AutoSize = $true
$monthTotalPanel.Controls.Add($monthTotalTitleLabel)

$monthPointsLabel = New-Object System.Windows.Forms.Label
$monthPointsLabel.Text = "0 pts"
$monthPointsLabel.ForeColor = [System.Drawing.Color]::Orange
$monthPointsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$monthPointsLabel.Location = New-Object System.Drawing.Point(10, 35)
$monthPointsLabel.AutoSize = $true
$monthTotalPanel.Controls.Add($monthPointsLabel)

# Notes Panel
$notesPanel = New-Object System.Windows.Forms.Panel
$notesPanel.Location = New-Object System.Drawing.Point(20, 480)
$notesPanel.Size = New-Object System.Drawing.Size(400, 280)
$notesPanel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 75)
$form.Controls.Add($notesPanel)
Set-RoundedCorners $notesPanel 15

$notesTitleLabel = New-Object System.Windows.Forms.Label
$notesTitleLabel.Text = "DAILY NOTES"
$notesTitleLabel.ForeColor = [System.Drawing.Color]::White
$notesTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$notesTitleLabel.Location = New-Object System.Drawing.Point(10, 10)
$notesTitleLabel.AutoSize = $true
$notesPanel.Controls.Add($notesTitleLabel)

$selectedDateLabel = New-Object System.Windows.Forms.Label
$selectedDateLabel.Text = "No date selected"
$selectedDateLabel.ForeColor = [System.Drawing.Color]::Gray
$selectedDateLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$selectedDateLabel.Location = New-Object System.Drawing.Point(10, 35)
$selectedDateLabel.AutoSize = $true
$notesPanel.Controls.Add($selectedDateLabel)

$notesTextBox = New-Object System.Windows.Forms.TextBox
$notesTextBox.Location = New-Object System.Drawing.Point(10, 60)
$notesTextBox.Size = New-Object System.Drawing.Size(380, 180)
$notesTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$notesTextBox.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 100)
$notesTextBox.ForeColor = [System.Drawing.Color]::White
$notesTextBox.Multiline = $true
$notesTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$notesPanel.Controls.Add($notesTextBox)
Set-RoundedCorners $notesTextBox 10

$saveNoteBtn = New-Object System.Windows.Forms.Button
$saveNoteBtn.Text = "Save Note"
$saveNoteBtn.Location = New-Object System.Drawing.Point(10, 245)
$saveNoteBtn.Size = New-Object System.Drawing.Size(100, 30)
$saveNoteBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 200)
$saveNoteBtn.ForeColor = [System.Drawing.Color]::White
$saveNoteBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$saveNoteBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$saveNoteBtn.FlatAppearance.BorderSize = 0
$saveNoteBtn.Add_Click({
    Save-CurrentNote
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Saved!"
    $statusLabel.ForeColor = [System.Drawing.Color]::Lime
    $statusLabel.Location = New-Object System.Drawing.Point(120, 250)
    $statusLabel.AutoSize = $true
    $notesPanel.Controls.Add($statusLabel)
    $form.Refresh()
    Start-Sleep -Milliseconds 1200
    $notesPanel.Controls.Remove($statusLabel)
})
$notesPanel.Controls.Add($saveNoteBtn)
Set-RoundedCorners $saveNoteBtn 10

# Calendar Panel
$calendarPanel = New-Object System.Windows.Forms.Panel
$calendarPanel.Location = New-Object System.Drawing.Point(440, 20)
$calendarPanel.Size = New-Object System.Drawing.Size(820, 740)
$calendarPanel.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
$form.Controls.Add($calendarPanel)

$prevBtn = New-Object System.Windows.Forms.Button
$prevBtn.Text = "<"
$prevBtn.Location = New-Object System.Drawing.Point(20, 15)
$prevBtn.Size = New-Object System.Drawing.Size(50, 40)
$prevBtn.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$prevBtn.ForeColor = [System.Drawing.Color]::White
$prevBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$prevBtn.FlatAppearance.BorderSize = 0
$prevBtn.Add_Click({
    $script:displayMonth = $script:displayMonth.AddMonths(-1)
    UpdateCalendar
})
$calendarPanel.Controls.Add($prevBtn)
Set-RoundedCorners $prevBtn 10

$nextBtn = New-Object System.Windows.Forms.Button
$nextBtn.Text = ">"
$nextBtn.Location = New-Object System.Drawing.Point(750, 15)
$nextBtn.Size = New-Object System.Drawing.Size(50, 40)
$nextBtn.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$nextBtn.ForeColor = [System.Drawing.Color]::White
$nextBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$nextBtn.FlatAppearance.BorderSize = 0
$nextBtn.Add_Click({
    $script:displayMonth = $script:displayMonth.AddMonths(1)
    UpdateCalendar
})
$calendarPanel.Controls.Add($nextBtn)
Set-RoundedCorners $nextBtn 10

$monthLabel = New-Object System.Windows.Forms.Label
$monthLabel.Text = (Get-Date).ToString("MMMM yyyy")
$monthLabel.ForeColor = [System.Drawing.Color]::White
$monthLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$monthLabel.Location = New-Object System.Drawing.Point(280, 15)
$monthLabel.Size = New-Object System.Drawing.Size(240, 40)
$monthLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$calendarPanel.Controls.Add($monthLabel)

$calendarMonthTotalLabel = New-Object System.Windows.Forms.Label
$calendarMonthTotalLabel.Text = "MONTH: 0 pts"
$calendarMonthTotalLabel.ForeColor = [System.Drawing.Color]::White
$calendarMonthTotalLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$calendarMonthTotalLabel.Location = New-Object System.Drawing.Point(250, 15)
$calendarMonthTotalLabel.Size = New-Object System.Drawing.Size(300, 40)
$calendarMonthTotalLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$calendarPanel.Controls.Add($calendarMonthTotalLabel)

$dailyAverageLabel = New-Object System.Windows.Forms.Label
$dailyAverageLabel.Text = "DAILY AVG: 0 pts"
$dailyAverageLabel.ForeColor = [System.Drawing.Color]::White
$dailyAverageLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$dailyAverageLabel.Location = New-Object System.Drawing.Point(250, 55)
$dailyAverageLabel.Size = New-Object System.Drawing.Size(300, 30)
$dailyAverageLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$calendarPanel.Controls.Add($dailyAverageLabel)

# Weekday headers
$weekdays = @("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")
$headerPositions = @(15, 128, 241, 354, 467, 580, 693)
for ($i = 0; $i -lt 7; $i++) {
    $header = New-Object System.Windows.Forms.Label
    $header.Text = $weekdays[$i]
    $header.Size = New-Object System.Drawing.Size(110, 35)
    $header.Location = New-Object System.Drawing.Point($headerPositions[$i], 95)
    $header.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $header.ForeColor = [System.Drawing.Color]::White
    $header.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $header.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $header.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $calendarPanel.Controls.Add($header)
    Set-RoundedCorners $header 8
}

function GetColorForPoints($points) {
    if ($points -eq 0) { return [System.Drawing.Color]::FromArgb(70, 130, 180) }
    elseif ($points -lt 0) { return [System.Drawing.Color]::FromArgb(139, 0, 0) }
    elseif ($points -le 1) { return [System.Drawing.Color]::FromArgb(139, 0, 0) }
    elseif ($points -le 2) { return [System.Drawing.Color]::FromArgb(163, 0, 0) }
    elseif ($points -le 3) { return [System.Drawing.Color]::FromArgb(184, 0, 0) }
    elseif ($points -le 4) { return [System.Drawing.Color]::FromArgb(208, 0, 0) }
    elseif ($points -le 5) { return [System.Drawing.Color]::FromArgb(224, 0, 0) }
    elseif ($points -le 6) { return [System.Drawing.Color]::FromArgb(255, 0, 0) }
    elseif ($points -le 7) { return [System.Drawing.Color]::FromArgb(255, 42, 0) }
    elseif ($points -le 8) { return [System.Drawing.Color]::FromArgb(255, 85, 0) }
    elseif ($points -le 9) { return [System.Drawing.Color]::FromArgb(255, 128, 0) }
    elseif ($points -le 10) { return [System.Drawing.Color]::FromArgb(255, 170, 0) }
    elseif ($points -le 11) { return [System.Drawing.Color]::FromArgb(255, 213, 0) }
    elseif ($points -le 12) { return [System.Drawing.Color]::FromArgb(255, 255, 0) }
    elseif ($points -le 13) { return [System.Drawing.Color]::FromArgb(212, 255, 0) }
    elseif ($points -le 14) { return [System.Drawing.Color]::FromArgb(160, 255, 0) }
    else { return [System.Drawing.Color]::FromArgb(0, 255, 0) }
}

# Calendar cells - Using old working per-cell click handlers
$script:dayCells = @()
$xPositions = @(15, 128, 241, 354, 467, 580, 693)
$yPositions = @(135, 238, 341, 444, 547, 650)
for ($row = 0; $row -lt 6; $row++) {
    for ($col = 0; $col -lt 7; $col++) {
        $cell = New-Object System.Windows.Forms.Panel
        $cell.Size = New-Object System.Drawing.Size(110, 100)
        $cell.Location = New-Object System.Drawing.Point($xPositions[$col], $yPositions[$row])
        $cell.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
        $cell.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $cell.Cursor = [System.Windows.Forms.Cursors]::Hand
        $calendarPanel.Controls.Add($cell)
        Set-RoundedCorners $cell 8

        $cell.Add_Click({
            $clickedCellInfo = $this.Tag
            if ($clickedCellInfo.Day -and $clickedCellInfo.Day -gt 0) {
                $script:selectedDate = New-Object DateTime $script:displayMonth.Year, $script:displayMonth.Month, $clickedCellInfo.Day
                $datePicker.Value = $script:selectedDate
                LoadNoteForSelectedDate
                UpdateSelectionOnly
            }
        })

        $dayNum = New-Object System.Windows.Forms.Label
        $dayNum.Size = New-Object System.Drawing.Size(40, 25)
        $dayNum.Location = New-Object System.Drawing.Point(5, 5)
        $dayNum.ForeColor = [System.Drawing.Color]::Black
        $dayNum.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $dayNum.BackColor = [System.Drawing.Color]::Transparent
        $cell.Controls.Add($dayNum)
        $dayNum.Add_Click({
            $clickedCellInfo = $this.Parent.Tag
            if ($clickedCellInfo.Day -and $clickedCellInfo.Day -gt 0) {
                $script:selectedDate = New-Object DateTime $script:displayMonth.Year, $script:displayMonth.Month, $clickedCellInfo.Day
                $datePicker.Value = $script:selectedDate
                LoadNoteForSelectedDate
                UpdateSelectionOnly
            }
        })

        $ptsLabel = New-Object System.Windows.Forms.Label
        $ptsLabel.Size = New-Object System.Drawing.Size(100, 50)
        $ptsLabel.Location = New-Object System.Drawing.Point(5, 35)
        $ptsLabel.ForeColor = [System.Drawing.Color]::Black
        $ptsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $ptsLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $ptsLabel.BackColor = [System.Drawing.Color]::Transparent
        $cell.Controls.Add($ptsLabel)
        $ptsLabel.Add_Click({
            $clickedCellInfo = $this.Parent.Tag
            if ($clickedCellInfo.Day -and $clickedCellInfo.Day -gt 0) {
                $script:selectedDate = New-Object DateTime $script:displayMonth.Year, $script:displayMonth.Month, $clickedCellInfo.Day
                $datePicker.Value = $script:selectedDate
                LoadNoteForSelectedDate
                UpdateSelectionOnly
            }
        })

        $starLabel = New-Object System.Windows.Forms.Label
        $starLabel.Size = New-Object System.Drawing.Size(100, 20)
        $starLabel.Location = New-Object System.Drawing.Point(5, 75)
        $starLabel.ForeColor = [System.Drawing.Color]::Black
        $starLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $starLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $starLabel.BackColor = [System.Drawing.Color]::Transparent
        $cell.Controls.Add($starLabel)

        $cellInfo = @{
            Panel     = $cell
            DayNum    = $dayNum
            PtsLabel  = $ptsLabel
            StarLabel = $starLabel
            Row       = $row
            Col       = $col
            Day       = $null
        }
        $cell.Tag = $cellInfo
        $script:dayCells += $cellInfo
    }
}

# Update today's total
function UpdateTodayTotal {
    $todayDate = (Get-Date).ToString("yyyy-MM-dd")
    $todayTotal = ($script:data | Where-Object { $_.Date -eq $todayDate -and $_.Category -ne "Note" } | Measure-Object -Property Points -Sum).Sum
    if ($null -eq $todayTotal) { $todayTotal = 0 }
    $todayDisplay = "{0:N1}" -f [math]::Round($todayTotal, 1)
    $todayPointsLabel.Text = "$todayDisplay pts"
}

# Highlight selected day with white border
function UpdateSelectionOnly {
    foreach ($cellInfo in $script:dayCells) {
        $cellInfo.Panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    }
    foreach ($cellInfo in $script:dayCells) {
        if (-not $cellInfo.Day) { continue }
        if ($script:displayMonth.Year -eq $script:selectedDate.Year -and $script:displayMonth.Month -eq $script:selectedDate.Month -and $cellInfo.Day -eq $script:selectedDate.Day) {
            $cellInfo.Panel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
        }
    }
    $calendarPanel.Refresh()
}

# Update calendar display
function UpdateCalendar {
    $firstDay = New-Object DateTime $script:displayMonth.Year, $script:displayMonth.Month, 1
    $daysInMonth = [DateTime]::DaysInMonth($script:displayMonth.Year, $script:displayMonth.Month)
    $startDayOfWeek = [int]$firstDay.DayOfWeek
    $monthLabel.Text = $script:displayMonth.ToString("MMMM yyyy")

    foreach ($cellInfo in $script:dayCells) {
        $cellInfo.Panel.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
        $cellInfo.DayNum.Text = ""
        $cellInfo.PtsLabel.Text = ""
        $cellInfo.StarLabel.Text = ""
        $cellInfo.Panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $cellInfo.Day = $null
    }

    $monthTotal = 0
    $daysWithPoints = 0
    for ($day = 1; $day -le $daysInMonth; $day++) {
        $index = $startDayOfWeek + $day - 1
        if ($index -lt $script:dayCells.Count) {
            $cellInfo = $script:dayCells[$index]
            $cellInfo.DayNum.Text = $day.ToString()
            $cellInfo.Day = $day
            $dayDate = $firstDay.AddDays($day - 1).ToString("yyyy-MM-dd")
            $dayEntries = $script:data | Where-Object { $_.Date -eq $dayDate -and $_.Category -ne "Note" }
            $dayTotal = ($dayEntries | Measure-Object -Property Points -Sum).Sum
            if ($null -eq $dayTotal) { $dayTotal = 0 }
            $monthTotal += $dayTotal
            if ($dayTotal -ne 0) { $daysWithPoints++ }

            $displayValue = "{0:N1}" -f [math]::Round($dayTotal, 1)
            $cellInfo.PtsLabel.Text = $displayValue

            if ($dayTotal -eq 0) {
                $cellInfo.Panel.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
                $cellInfo.DayNum.ForeColor = [System.Drawing.Color]::Black
                $cellInfo.PtsLabel.ForeColor = [System.Drawing.Color]::Black
            } elseif ($dayTotal -lt 0) {
                $cellInfo.Panel.BackColor = [System.Drawing.Color]::FromArgb(139, 0, 0)
                $cellInfo.DayNum.ForeColor = [System.Drawing.Color]::White
                $cellInfo.PtsLabel.ForeColor = [System.Drawing.Color]::White
            } else {
                $cellInfo.Panel.BackColor = GetColorForPoints([math]::Floor($dayTotal))
                $cellInfo.DayNum.ForeColor = [System.Drawing.Color]::Black
                $cellInfo.PtsLabel.ForeColor = [System.Drawing.Color]::Black
            }

            if ($dayTotal -gt 15) {
                $starCount = [math]::Floor($dayTotal / 15)
                $stars = ""
                for ($i = 0; $i -lt [math]::Min($starCount, 3); $i++) {
                    $stars += "★"
                }
                $cellInfo.StarLabel.Text = $stars
            }
        }
    }

    $dailyAverage = if ($daysWithPoints -gt 0) { $monthTotal / $daysWithPoints } else { 0 }
    $monthDisplay = "{0:N1}" -f [math]::Round($monthTotal, 1)
    $avgDisplay = "{0:N1}" -f [math]::Round($dailyAverage, 1)
    $monthPointsLabel.Text = "$monthDisplay pts"
    $calendarMonthTotalLabel.Text = "MONTH: $monthDisplay pts"
    $dailyAverageLabel.Text = "DAILY AVG: $avgDisplay pts"

    UpdateTodayTotal
    UpdateSelectionOnly
}

# Initialize
$datePicker.Value = $script:selectedDate
LoadNoteForSelectedDate
UpdateCalendar
$form.ShowDialog()