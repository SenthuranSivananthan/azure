New-AzureRmResourceGroupDeployment `
    -Name "deploy" `
    -ResourceGroupName "test-ai-webtest" `
    -TemplateFile ".\add-webtest.json"