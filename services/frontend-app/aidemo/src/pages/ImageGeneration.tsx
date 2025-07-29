import React, { useState} from 'react';
import '../index.css';
import Button from '../components/Button';
import getConfigurationProperties from '../utils/getConfigurationProperties';

export interface IHomeProps {}

const ImageGeneration: React.FunctionComponent<IHomeProps> = () => {

    const configurationProperties = getConfigurationProperties();
    const [prompt, setPrompt] = useState("Product photoshoot of a flower vase and a calculator set on a table, shallow depth of field");
    const [response, setResponse] = useState("");
    const [modelId, setModelId] = useState("");
    const [generatedImage, setGeneratedImage] = useState("");

    const handleClick = async () => {

    const restURL = configurationProperties.baseUrl+'/prod/imagegeneration';
    let promptJSON = '{ "prompt" : "'+prompt+'"}'

    setResponse("")
    setModelId("");
    setGeneratedImage("");


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

    //console.log("data="+JSON.stringify(data))

    //setResponse(data)
    setModelId(data[0]['modelId']);
    setGeneratedImage(data[0]['imageurl']);

  };


    return (
    <div>
        <h2 className="font-bold">Image Generation</h2>
        <div className="grid grid-cols-1">
<div>
<div className="">






                  </div>
</div>
<div>
<div className="relative w-full min-w-[200px]">
    <textarea
      className="peer h-full min-h-[100px] w-full resize-none rounded-[7px] border border-blue-gray-200 border-t-transparent bg-transparent px-3 py-2.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border placeholder-shown:border-blue-gray-200 placeholder-shown:border-t-blue-gray-200 focus:border-2 focus:border-gray-900 focus:border-t-transparent focus:outline-0 disabled:resize-none disabled:border-0 disabled:bg-blue-gray-50"
      placeholder=" "
      
            required
      value={prompt}
      onChange={(e) => setPrompt(e.target.value)}  
      
      ></textarea>
    <label
      className="before:content[' '] after:content[' '] pointer-events-none absolute left-0 -top-1.5 flex h-full w-full select-none text-[11px] font-normal leading-tight text-blue-gray-400 transition-all before:pointer-events-none before:mt-[6.5px] before:mr-1 before:box-border before:block before:h-1.5 before:w-2.5 before:rounded-tl-md before:border-t before:border-l before:border-blue-gray-200 before:transition-all after:pointer-events-none after:mt-[6.5px] after:ml-1 after:box-border after:block after:h-1.5 after:w-2.5 after:flex-grow after:rounded-tr-md after:border-t after:border-r after:border-blue-gray-200 after:transition-all peer-placeholder-shown:text-sm peer-placeholder-shown:leading-[3.75] peer-placeholder-shown:text-blue-gray-500 peer-placeholder-shown:before:border-transparent peer-placeholder-shown:after:border-transparent peer-focus:text-[11px] peer-focus:leading-tight peer-focus:text-gray-900 peer-focus:before:border-t-2 peer-focus:before:border-l-2 peer-focus:before:border-gray-900 peer-focus:after:border-t-2 peer-focus:after:border-r-2 peer-focus:after:border-gray-900 peer-disabled:text-transparent peer-disabled:before:border-transparent peer-disabled:after:border-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500">
      Prompt
    </label>
  </div>


</div>
<div><div><Button type="2" label="Submit" onClick={handleClick} /></div>
</div>
          

<div><label className="font-bold text-black">Generated Image:</label></div>
<div>{
  generatedImage ? (<img src={generatedImage} />): (<p>No image</p>)
}</div>
<div><label className="font-bold text-black">Cost:</label>Amazon Nova Canvas $0.04 per image (up to 1024 x 1024 images) https://aws.amazon.com/bedrock/pricing/</div>
<div><div style={{ whiteSpace: 'pre-wrap' }}>{response}</div></div>
<div><label className="font-bold text-black">ModelId:</label> {modelId}  </div>

        </div>

    </div>
    );
  }
export default ImageGeneration;