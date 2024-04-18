# Ajuste o $rootFolder abaixo para apontar onde tem repositorio do projeto na sua maquina:
$rootFolder = "C:\Users\adam.wandoch\source\repos\SRM.wbc7srm"

# Inicializar o timer
$scriptStartTime = Get-Date

# Inicializar os arrays para gravar quantidades por idioma
$reportData = @()
$languageCounts = @{
    'Ingles' = 0
    'Espanhol (Espanha)' = 0
    'Espanhol (Paraguay)' = 0
    'Espanhol (Mexico)' = 0
    'Outros' = 0
}

# Inicializar o counter
$global:counter = 1  

# Buscar todos .resx com tags da traducao
$resxFiles = Get-ChildItem -Path $rootFolder -Filter '*.resx' -File -Recurse

$rootFolderLength = $rootFolder.Length  

foreach ($resxFile in $resxFiles) {
    # Obter o caminho relativo
    $relativePath = $resxFile.FullName.Substring($rootFolderLength + 1)  
    $content = Get-Content $resxFile.FullName
    $xml = [xml]$content

    # Confirmar se o .resx tem valores especificados (case-insensitive)
    foreach ($data in $xml.root.data) {
        $value = $data.value
        if ($value -match '(?i)en-us|es-es|es-py|es-mx') {
            
            # Definir o nome da cultura
            $language = if ($value -match '(?i)en-us') { 'Ingles' }
                        elseif ($value -match '(?i)es-es') { 'Espanhol (Espanha)' }
                        elseif ($value -match '(?i)es-py') { 'Espanhol (Paraguay)' }
                        elseif ($value -match '(?i)es-mx') { 'Espanhol (Mexico)' }
                        else { 'Outros' }

            $languageCounts[$language]++
            
            $reportData += [PSCustomObject]@{
                'Idioma Destino' = $language
                'Valor' = $data.value
                'Recurso' = $data.name
                'Arquivo' = $resxFile.Name
                'Caminho' = $relativePath  
            }
            Write-Host $global:counter":" $resxFile.Name "|" $data.name "|" $data.value
            $global:counter++
        }
    }
}
$counter--

$scriptEndTime = Get-Date
$executionTime = $scriptEndTime - $scriptStartTime

$currentDateTime = Get-Date -Format "yyyy-MM-dd HH-mm-ss"

# Exportar os dados na planilha CSV com UTF-8 encoding
$reportFileName = "Paradigma - WBC - Relatorio De Traducoes $currentDateTime.csv"
$reportData | Export-Csv -Path $reportFileName -NoTypeInformation -Encoding UTF8
$reportFilePath = (Get-Item -Path $reportFileName).FullName

Write-Host 
Write-Host "Total registros encontrados para traducao: "($counter)
Write-Host 

# Mostrar o summary no console

$sortedLanguageCounts = $languageCounts.GetEnumerator() | Sort-Object -Property Value -Descending

foreach ($language in $sortedLanguageCounts) {
    Write-Host "$($language.Name): $($language.Value)"
}

Write-Host 
Write-Host "Tempo de execucao (HH:mm:ss) - $executionTime"
Write-Host 
Write-Host "Gerado relatorio em: $reportFilePath"
Write-Host 
