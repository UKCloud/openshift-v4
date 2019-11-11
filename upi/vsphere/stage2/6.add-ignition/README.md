# PowerShell to add ignition details (after openshift-install has been ran)

syntax:
```pwsh ./add_ignition.ps1 <inputfile> <outputfile> <masterignfile> <workerignfile> <infraignfile> <svcignfile> <bootstrapurl>```

example:
``` pwsh ./add-ignition.ps1 ./terraform.tfvars.json ./terraform.tfvars.json.out ~/openshift-install-linux-4.1.9/newconfig8/master.ign ~/openshift-install-linux-4.1.9/newconfig8/worker.ign ~/openshift-install-linux-4.1.9/newconfig8/infra.ign  ~/openshift-install-linux-4.1.9/newconfig8/svc.ign  https://gist.githubusercontent.com/gellner/18d581d5737eeacc4e562a97db96a1e4/raw/b27f0336fa2c17cfb733af44a120feed42cab8f0/bootstrap17.ign```


# To run in container...



