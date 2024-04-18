# Ajuste o $rootFolder abaixo para apontar onde tem repositorio do projeto na sua maquina
$rootFolder = "C:\Users\adam.wandoch\source\repos\SRM.wbc7srm"

$importFile = "import.csv"

# Confirmar se o arquivo da importacao existe
if (-not (Test-Path $importFile)) {
    Write-Host "Erro: Arquivo 'import.csv' nao encontrado."
    return
}

# Importar o CSV com semicolon/coma delimiter
$importData = Import-Csv -Path $importFile -Delimiter ";"

# Inicializar o counter
$global:counter = 0

foreach ($importEntry in $importData) {
    
    # Obtenha o caminho relativo
    $relativePath = $importEntry.Caminho  
    
    # Combine o caminho relativo com o caminho da pasta raiz
    $fullPath = Join-Path -Path $rootFolder -ChildPath $relativePath  
    $recursoName = $importEntry.Recurso
    $novoValor = $importEntry.Valor
    
    # Confirmar se o arquivo .resx existe
    if (-not (Test-Path $fullPath)) {
        Write-Host "Erro: Arquivo .resx '$fullPath' nao encontrado."
        continue
    }
    $content = Get-Content -Path $fullPath -Encoding UTF8
    $xml = [xml]$content
    
    # Buscar o data node por nome
    $dataNode = $xml.root.data | Where-Object { $_.name -eq $recursoName }
    if ($null -ne $dataNode) {
        $oldValue = $dataNode.value  # Obtenha o valor atual
        
        # So atualize se o novo valor for diferente
        if ($novoValor -ne $oldValue) {
            
            # Define as strings a serem removidas
            $stringsToRemove = "en-us", "es-es", "es-py", "es-mx"

            # Remover ocorrências das strings especificadas de $novoValor
            foreach ($str in $stringsToRemove) {
                $novoValor = $novoValor -replace [regex]::Escape($str), ""
            }
            
            # Atualize o valor com o novo valor
            $dataNode.value = $novoValor
            
            # Salve o conteudo atualizado de volta no arquivo .resx
            $xml.Save($fullPath)
            
            # Incremente o contador de atualizacoes
            $global:counter++
            Write-Host $global:counter": $fullPath - $recursoName - Atualizado de '$oldValue' para '$novoValor'"
            Write-Host
            Write-Host "Procurando proximo ajuste..."
            Write-Host
        }
    }
}

# Exiba o numero total de atualizacoes
Write-Host "Total de atualizacoes: $global:counter"