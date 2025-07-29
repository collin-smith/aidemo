import React, { useEffect, useState }  from 'react';
import '../index.css';
import Button from '../components/Button';
//import getConfigurationProperties from '../utils/getConfigurationProperties';
import useFetch from "../hooks/useFetch";
import getConfigurationProperties from '../utils/getConfigurationProperties';

import * as Module from "../interfaces/DropdownOption";

import Dropdown from '../components/Dropdown';

export interface IHomeProps {}

//const Home: React.FunctionComponent<IHomeProps> = () => {
const DocumentAnalysis: React.FunctionComponent<IHomeProps> = () => {

    const configurationProperties = getConfigurationProperties();
    const [prompt, setPrompt] = useState("Summarize the following text in 3 sentences");
    const [text, setText] = useState("");
    const [results, setResults] = useState("");
    const [configured, setConfigured] = useState(false);

    const [modelId, setModelId] = useState("");
    const [inputTokens, setInputTokens] = useState("");
    const [outputTokens, setOutputTokens] = useState("");
    const [costReport, setCostReport] = useState("");
    const [exceptionMessage, setExceptionMessage] = useState("");


    const [dropdownOptions, setDropdownOptions] = useState<Module.DropdownOption[]>([]);
    const [selectedDropdownOption, setSelectedDropdownOption] = useState<Module.DropdownOption>({ value: "", label: "" })
    const { data: objects , error, isPending } = useFetch('/prod/objects/');
    if (error && isPending) { }




  useEffect(() => {
    //console.log("We are back from the call and have the objects")
        if (configured==false && objects !=null)
          {
 
            let objectArray = JSON.parse(JSON.stringify(objects))
 
            var list: Module.DropdownOption[] = [];
            for (let i = 0; i < objectArray.length; i++) {
              let im = objectArray[i];
              let obj: Module.DropdownOption = { value: "", label:""}
              obj.value = im.url
              obj.label = im.key

              //We are only going to analyze PDF object that have been processed by textract
              if (im.key.startsWith("textract/"))
              {

                let newLabel = obj.label.split('/')[1]
                newLabel = newLabel.split(".txt")[0]
                obj.label = newLabel
                list.push(obj)
              }
            }

            if (list.length==0)
            {
              let obj: Module.DropdownOption = { value: "", label:""}
              obj.value = "No pdfs available"
              obj.label = "No pdfs available"
              list.push(obj)
            }

            setDropdownOptions(list)
           // console.log("Updating Initially")
            setSelectedDropdownOption(list[0])
            setConfigured(true)
          }
  })



  const handleClick = async () => {
    //console.log('Button clicke)d');
    //console.log('prompt='+prompt);
    //console.log('dropdown options='+selectedDropdownOption.label+'=');

    setResults("")
    setText("")
    setModelId("");
    setInputTokens("");
    setOutputTokens("");
    setCostReport("");
    setExceptionMessage("");

    if (!("No pdfs available" == selectedDropdownOption.label))
    {
      const restURL = configurationProperties.baseUrl+'/prod/documentanalysis';
      let promptJSON = '{ "key" : "'+selectedDropdownOption.label+'", "prompt" :"'+prompt+'" }'
      console.log("Submitting to "+restURL)
      console.log("JSON= "+promptJSON)
      let headers = new Headers();
      headers.append('Content-Type', 'application/json');
      const response = await fetch(restURL, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify(promptJSON),
     });

   if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    let results= data[0]['results']
    setResults(results)
    setText(data[0]['text'])
    setModelId(data[0]['modelId']);
    setInputTokens(data[0]['inputTokens']);
    setOutputTokens(data[0]['outputTokens']);
    setCostReport(data[0]['costReport']);
    setExceptionMessage(data[0]['exceptionMessage']);

    
    }

  };

  const handleSelectChange = (index: number) => {
   // console.log("before selected option="+JSON.stringify(selectedDropdownOption))
    //console.log("COming back with number="+index)
    setSelectedDropdownOption(dropdownOptions[index])
   // setObjectName("ABC")
   // console.log("after selected option="+JSON.stringify(selectedDropdownOption))

  };
  
    return (

            <div className="border-0">
        <p className="font-bold">Document Analysis (PDFs)</p>
        <p className="font-bold">Submitting the Textract text to the LLM for processing.</p>
<div className="grid grid-cols-2">

          <div className="relative min-w-[200px] ">

            <textarea className="peer h-full min-h-[100px] w-full resize-none rounded-[7px] border border-blue-gray-200 border-t-transparent bg-transparent px-3 py-2.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border placeholder-shown:border-blue-gray-200 placeholder-shown:border-t-blue-gray-200 focus:border-2 focus:border-gray-900 focus:border-t-transparent focus:outline-0 disabled:resize-none disabled:border-0 disabled:bg-blue-gray-50" 
              placeholder=" "
             required
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}  
      >   </textarea>
          <label
          className="before:content[' '] after:content[' '] pointer-events-none absolute left-0 -top-1.5 flex w-full select-none text-[11px] font-normal leading-tight text-blue-gray-400 transition-all before:pointer-events-none before:mt-[6.5px] before:mr-1 before:box-border before:block before:h-1.5 before:w-2.5 before:rounded-tl-md before:border-t before:border-l before:border-blue-gray-200 before:transition-all after:pointer-events-none after:mt-[6.5px] after:ml-1 after:box-border after:block after:h-1.5 after:w-2.5 after:flex-grow after:rounded-tr-md after:border-t after:border-r after:border-blue-gray-200 after:transition-all peer-placeholder-shown:text-sm peer-placeholder-shown:leading-[3.75] peer-placeholder-shown:text-blue-gray-500 peer-placeholder-shown:before:border-transparent peer-placeholder-shown:after:border-transparent peer-focus:text-[11px] peer-focus:leading-tight peer-focus:text-gray-900 peer-focus:before:border-t-2 peer-focus:before:border-l-2 peer-focus:before:border-gray-900 peer-focus:after:border-t-2 peer-focus:after:border-r-2 peer-focus:after:border-gray-900 peer-disabled:text-transparent peer-disabled:before:border-transparent peer-disabled:after:border-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500">
          Prompt
          </label>
        </div>


        <div className="">

          <Dropdown selected={selectedDropdownOption} options={dropdownOptions} handleSelectChange={handleSelectChange} ></Dropdown>

        </div>

      <div  className="col-span-2 space-y-2 py-2">
  
          <Button type="2" label="Submit" onClick={handleClick} />

        </div>

<div className="col-span-2 space-y-2 py-2">
    <div className="pl-2 font-bold">Results </div><br></br>
    <div><div style={{ whiteSpace: 'pre-wrap' }}>{results}</div>

    </div>
  </div> 


<div className="col-span-2 space-y-2 py-2">
    <div className="pl-2 font-bold">PDF Text </div><br></br>
    <div><div style={{ whiteSpace: 'pre-wrap' }}>{text}</div>

    </div>
  </div> 

<div  className="col-span-2 space-y-2 py-2"><label className="font-bold text-black">ModelId:</label> {modelId}  </div>
<div  className="col-span-2 space-y-2 py-2"><label className="font-bold text-black">Input Tokens:</label> {inputTokens}  </div>
<div  className="col-span-2 space-y-2 py-2"><label className="font-bold text-black">Output Tokens:</label> {outputTokens}  </div>
<div  className="col-span-2 space-y-2 py-2"><label className="font-bold text-black">Cost Report:</label> {costReport}  </div>

<div  className="col-span-2 space-y-2 py-2">
          {
  exceptionMessage ? (<p><label className="font-bold text-red">Exception:</label> {exceptionMessage} </p>): (<p></p>)
}
  </div>


    </div>
    </div>
    );
  }
export default DocumentAnalysis;