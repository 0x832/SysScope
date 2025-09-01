
function banner {
    $banner = @'
╭━━━╮       ━━╮
┃╭━╮┃      ┃╭━╮┃
┃╰━━┳╮ ╭┳━━┫╰━━┳━━┳━━┳━━┳━━╮
╰━━╮┃┃ ┃┃━━╋━━╮┃╭━┫╭╮┃╭╮┃┃━┫
┃╰━╯┃╰━╯┣━━┃╰━╯┃╰━┫╰╯┃╰╯┃┃━┫
╰━━━┻━╮╭┻━━┻━━━┻━━┻━━┫╭━┻━━╯
   ╭━╯┃           ┃┃
   ╰━━╯           ╰╯

'@ -split "`n"

    foreach ($line in $banner) {
        Write-Host $line
        Start-Sleep -Milliseconds 200
    }
}

$procesosSospechosos = @(
    'mimikatz.exe','nc.exe','meterpreter.exe','powershell.exe','cmd.exe','wscript.exe','cscript.exe',
    
    'powersgell.exe','rundll32.exe','svchost.exe','explorer.exe','taskhostw.exe','regsvr32.exe','autorun.exe',

    'pythonw.exe','schtasks.exe','psexec.exe','mshta.exe','msbuild.exe','javaw.exe','conhost.exe'
)


function procesos_consume {
    Clear-Host

    $procesos_evidencia = Get-Process
   
    $procesos_filtrados = $procesos_evidencia |
        Where-Object { $_.WorkingSet -gt 100MB } |
        Select-Object ProcessName, CPU, @{Name="RAM_MB"; Expression = {[math]::Round($_.WorkingSet / 1MB, 2)}}, Id |
        Sort-Object -Property CPU, RAM_MB -Descending

     $procesos_filtrados | Format-Table -AutoSize

   
    $evidencias = Read-Host "Quieres exportar las evidencias? s/n"
    
    if ($evidencias -eq "s") {
        $filename = Read-Host "Introduce el nombre del fichero: "
        $archivo = Join-Path -Path $PSScriptRoot -ChildPath "$filename.csv"

        $procesos_filtrados | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -replace ',', ';' } | Set-Content -Path $archivo -Encoding UTF8

        Write-Host "Se guardó el registro en $archivo" -ForegroundColor Green
    }
}



function users {
    Clear-Host
    

    $usuario = Get-LocalUser | Select-Object Name, Description
       
    $usuario | Format-Table -AutoSize

    $evidencias = Read-Host "Quieres exportar las evidencias? s/n"
    2
    if ($evidencias -eq "s") {
        $filename = Read-Host "Introduce el nombre del fichero: "
        $archivo = Join-Path (Get-Location) "$filename.csv"


        $usuario | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -replace ',', ';' } | Set-Content -Path $archivo -Encoding UTF8

        Write-Host "Se guardó el registro en $archivo" -ForegroundColor Green
    }

}

function usuarios_grupos{
    Clear-Host

    
    $usuarios_evidencia = Get-Process
    $usuario_filtrados = Get-LocalGroup | ForEach-Object {
        $group = $_.Name
        Get-LocalGroupMember -Group $group | Select-Object @{Name="Group"; Expression = {$group}}, Name
    }


    $usuario_filtrados | Format-Table -AutoSize

    
    $evidencias = Read-Host "Quieres exportar las evidencias? s/n"
    if ($evidencias -eq "s") {
        $filename = Read-Host "Introduce el nombre del fichero: "
        $archivo = Join-Path (Get-Location) "$filename.csv"

        $usuario_filtrados |  ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -replace ',', ';' } | Set-Content -Path $archivo -Encoding UTF8

        Write-Host "Se guardó el registro en $archivo" -ForegroundColor Green
    }

}




function procesos{

    Clear-Host

    $procesos = Get-Process | Select-Object Id,ProcessName,Path,StartTime,CPU,WS

    $encontrados = $procesos | Where-Object {
        $procesosSospechosos -contains ($_.ProcessName.ToLower() + ".exe")
    }

    if ($encontrados) {
        Write-Host "Atencion! Se han encontrado procesos potencialmente peligrosos" -ForegroundColor Red
       
        $evidencias = Read-Host "Quieres exportar las evidencias? s/n"
    
        if ($evidencias -eq "s"){
            $filename = Read-Host "Introduce el nombre del fichero: "
            $archivo = Join-Path -Path $PSScriptRoot -ChildPath "$filename.csv"
   
    
            $encontrados | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -replace ',', ';' } | Set-Content -Path $archivo -Encoding UTF8

            Write-Host "Se guardo el registro en $archivo" -ForegroundColor Red
        }

        else{
            #no hacer nada        
        } 

        $encontrados | Format-Table Id,ProcessName,Path,StartTime,CPU,WS -AutoSize   
    


    } else {
        Write-Host "No se han detectado procesos sospechosos en ejecucion." -ForegroundColor Green

    }

}



function inicio {
    Clear-Host
    banner

    Write-Host ""
    Write-Host "1 - Lista de procesos que más consumen"
    Write-Host "2 - Ver Usuarios del sistema"
    Write-Host "3 - Usuarios asociados a grupos"
    Write-Host "4 - Analisis de posible proceso MALICIOSO
    "

    $opcion = Read-Host "Seleccione la opción deseada"

    switch ($opcion) {
        1 {
            procesos_consume
                    
        }

        2 {
            users

        }

        3 {
            usuarios_grupos
        
        }

        4 {
            procesos
        }

        Default {
            Write-Host "Opción no válida. Intente de nuevo."
        }
    }
}

inicio
