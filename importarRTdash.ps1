# Ajuste o $rootFolder abaixo para apontar para a pasta do repositorio do projeto na sua maquina
$rootFolder = "C:\Users\adam.wandoch\source\repos\dashboard-web"

$importFile = "import.csv"

# Confirmar se o arquivo de importacao existe
if (-not (Test-Path $importFile)) {
    Write-Host "Erro: Arquivo 'import.csv' nao encontrado."
    return
}
$importData = Import-Csv -Path $importFile

# Inicializar o contador
$global:counter = 0

foreach ($importEntry in $importData) {
    
    # Obter o caminho relativo
    $relativePath = $importEntry.Caminho  
    
    # Combinar o caminho relativo com o caminho da pasta raiz
    $fullPath = Join-Path -Path $rootFolder -ChildPath $relativePath
    $recursoName = $importEntry.Recurso
    $novoValor = $importEntry.Valor
    
    # Confirmar se o arquivo JSON existe
    if (-not (Test-Path $fullPath)) {
        Write-Host "Erro: Arquivo JSON '$fullPath' nao encontrado."
        continue
    }
    
    $jsonContent = Get-Content $fullPath | ConvertFrom-Json

    # Encontrar a chave correspondente na secao 'translation'
    $key = $jsonContent.translation.PSObject.Properties | Where-Object { $_.Name -eq $recursoName }

    if ($key) {
        $oldValue = $key.Value  # Obter o valor atual
        
        # Atualizar apenas se o novo valor for diferente
        if ($novoValor -ne $oldValue) {
            # Atualizar o valor com o novo
            $key.Value = $novoValor
            
            # Salvar o conteudo atualizado de volta para o arquivo JSON
            $jsonContent | ConvertTo-Json | Set-Content $fullPath -Force

            # Incrementar o contador de atualizacoes
            $global:counter++
            Write-Host $global:counter ": $fullPath - $recursoName - Atualizado de '$oldValue' para '$novoValor'"
            Write-Host
            Write-Host "Procurando a proxima atualizacao..."
            Write-Host
        }
    }
}

# Exibir o numero total de atualizacoes
Write-Host "Total de atualizacoes: $global:counter"
