[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ajuste o $rootFolder abaixo para apontar para a pasta do repositorio do projeto na sua maquina:
$rootFolder = "C:\Users\adam.wandoch\source\repos\dashboard-web"

# Inicializar o temporizador
$scriptStartTime = Get-Date

# Inicializar arrays para registrar contagens por idioma
$reportData = @()
$languageCounts = @{
    'Ingles' = 0
    'Espanhol (Espanha)' = 0
    'Espanhol (Paraguai)' = 0
    'Espanhol (Mexico)' = 0
    'Outros' = 0
}

# Inicializar o contador
$global:counter = 1  

# Buscar todos os arquivos JSON com etiquetas de traducao
$jsonFiles = Get-ChildItem -Path $rootFolder -Filter 'messages.json' -File -Recurse

$rootFolderLength = $rootFolder.Length  

foreach ($jsonFile in $jsonFiles) {
    # Obter o caminho relativo
    $relativePath = $jsonFile.FullName.Substring($rootFolderLength + 1)  
    $jsonContent = Get-Content $jsonFile.FullName -Encoding UTF8 | ConvertFrom-Json

    # Inicializar uma bandeira para verificar se o JSON contem algum codigo de idioma especificado
    $containsLanguage = $false

    foreach ($property in $jsonContent.translation.PSObject.Properties) {
        if ($property.Value -match '(?i)en-us|es-es|es-py|es-mx') {
            $containsLanguage = $true

            $languageCode = if ($property.Value -match '(?i)en-us') { 'Ingles' }
                            elseif ($property.Value -match '(?i)es-es') { 'Espanhol (Espanha)' }
                            elseif ($property.Value -match '(?i)es-py') { 'Espanhol (Paraguai)' }
                            elseif ($property.Value -match '(?i)es-mx') { 'Espanhol (Mexico)' }
                            else { 'Outros' }

            $languageCounts[$languageCode]++

            $reportData += [PSCustomObject]@{
                'Idioma Destino' = $languageCode
                'Valor' = $property.Value
                'Recurso' = $property.Name
                'Arquivo' = $jsonFile.Name
                'Caminho' = $relativePath
            }
            Write-Host $global:counter":" $jsonFile.Name "|" $property.Name "|" $property.Value
            $global:counter++
        }
    }

    if (!$containsLanguage) {
        # Lidar com casos em que nenhum codigo de idioma especificado foi encontrado
        $languageCounts['Outros']++
    }
}

$counter--

$scriptEndTime = Get-Date
$executionTime = $scriptEndTime - $scriptStartTime

$currentDateTime = Get-Date -Format "yyyy-MM-dd HH-mm-ss"

# Exportar os dados para um arquivo CSV com codificacao UTF-8
$reportFileName = "Paradigma - Dash - Relatorio de Traducoes $currentDateTime.csv"
$reportData | Export-Csv -Path $reportFileName -NoTypeInformation -Encoding UTF8 -UseCulture
# $reportData | Export-Csv -Path $reportFileName -NoTypeInformation -Encoding UTF8
$reportFilePath = (Get-Item -Path $reportFileName).FullName

Write-Host 
Write-Host "Total de registros encontrados para traducao: "($counter)
Write-Host 

# Mostrar o resumo no console

$sortedLanguageCounts = $languageCounts.GetEnumerator() | Sort-Object -Property Value -Descending

foreach ($language in $sortedLanguageCounts) {
    Write-Host "$($language.Name): $($language.Value)"
}

Write-Host 
Write-Host "Tempo de execucao (HH:mm:ss) - $executionTime"
Write-Host 
Write-Host "Relatorio gerado em: $reportFilePath"
Write-Host
