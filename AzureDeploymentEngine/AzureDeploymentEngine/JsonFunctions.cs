﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace AzureDeploymentEngine
{
    public class JsonFunctions
    {
        public AzureDeploymentEngine.Project ConvertToProjectFromJson(string JsonString)
        {
            //JsonSerializerSettings jsonSettings = new JsonSerializerSettings();
            //jsonSettings.NullValueHandling = NullValueHandling.Ignore;
            AzureDeploymentEngine.Project ConvertedObject = JsonConvert.DeserializeObject<AzureDeploymentEngine.Project>(JsonString);
                return ConvertedObject;
        }

        public string ConvertFromDeploymentToJson(AzureDeploymentEngine.Project DeploymentObj)
        {
            //JsonSerializerSettings jsonSettings = new JsonSerializerSettings();
            //jsonSettings.NullValueHandling = NullValueHandling.Ignore;
            Formatting JsonFormat = Formatting.Indented;

            string converted = JsonConvert.SerializeObject(DeploymentObj, JsonFormat);
            return converted;
        }

        public AzureDeploymentEngine.Vm ConvertToVmFromJson(string JsonString)
        {
            //JsonSerializerSettings jsonSettings = new JsonSerializerSettings();
            //jsonSettings.NullValueHandling = NullValueHandling.Ignore;
            AzureDeploymentEngine.Vm ConvertedObject = JsonConvert.DeserializeObject<AzureDeploymentEngine.Vm>(JsonString);
            return ConvertedObject;
        }
    }
}
