import React, { useState, } from 'react';

import '../index.css';
import getConfigurationProperties from '../utils/getConfigurationProperties';



export interface IUploadImageProps {}

const Upload: React.FunctionComponent<IUploadImageProps> = () => {

  const configurationProperties = getConfigurationProperties();
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [boldStatus, setBoldStatus] = useState(false);
  const [uploadStatus, setUploadStatus] = useState('');
  const [displayImage, setDisplayImage] = useState<string>("");

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0] || null;
    setSelectedFile(file);
    setUploadStatus("Selected "+file?.name)
    setDisplayImage("");
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      return;
    }

    //Get Presigned URL Object
    //Call for the presigned url
    const restURL = configurationProperties.baseUrl+'/prod/presignedurl';
     
    let key = selectedFile.name;
      let headers = new Headers();
      headers.append('Content-Type', 'application/json');
      const response = await fetch(restURL, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify({
        objectname: key
      }),
    });

   if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
        let presignedUrlProperties = {
    "url":"",
    "AWSAccessKeyId":"",
    "key":  "",
    "policy":  "",
    "signature":  "",
    "x-amz-security-token":  ""};
    presignedUrlProperties["key"] = key;
    presignedUrlProperties["url"] = data[0]['presignedUrl']["url"];
    presignedUrlProperties["AWSAccessKeyId"] = data[0]['presignedUrl']['fields']['AWSAccessKeyId'];
    presignedUrlProperties["x-amz-security-token"] = data[0]['presignedUrl']['fields']['x-amz-security-token'];
    presignedUrlProperties["policy"] = data[0]['presignedUrl']['fields']['policy'];
    presignedUrlProperties["signature"] = data[0]['presignedUrl']['fields']['signature'];
 

    const formData = new FormData();
    formData.append('AWSAccessKeyId', presignedUrlProperties.AWSAccessKeyId);
    formData.append('key', presignedUrlProperties.key);
    formData.append('policy', presignedUrlProperties.policy);
    formData.append('signature', presignedUrlProperties.signature);
    formData.append('x-amz-security-token', presignedUrlProperties['x-amz-security-token']);
    formData.append('file', selectedFile);
    setUploadStatus("Uploading "+selectedFile?.name);
    setBoldStatus(true)
    try {
        let headers = new Headers();
        headers.append('Content-Type', selectedFile.type);
      const response = await fetch(presignedUrlProperties.url, {
        method: 'POST',
        body: formData,
      });

      if (response.ok) {
        // Handle successful upload
        setDisplayImage(""+configurationProperties.cloudFrontDistribution+"/"+selectedFile.name)
        setBoldStatus(false)
        setUploadStatus("Successfully uploaded "+selectedFile?.name+ "(See below)")
      } else {
        // Handle upload error
        console.error('File upload failed');
      }
    } catch (error) {
      console.error('Error uploading file:', error);
    }

  };

    return (

      <div className="border-0">
        <p className="font-bold">File Upload</p>
        <p className="">Note: PDF files will trigger a Textract job to create a txt file of the contents of the pdf file.</p>
        <div className="grid grid-cols-1 border-0">

    <div   className="border-0">
      <input type="file"  className="file:border-1 hover:file:border-black file:bg-blue-300 hover:file:bg-blue-500 file:text-black hover:file:text-white file:font-bold file:px-4 file:py-2 file:rounded" onChange={handleFileChange} />
      {selectedFile && (
          <button className="btn-0" onClick={handleUpload}>Upload</button>
      )}
    </div>
 
 <div className="border-0">

      <p className={boldStatus ? "font-bold" : ""}>{uploadStatus}</p>

</div>
 <div className="border-0">
{
  displayImage ? (<img src={displayImage} />): (<p>No image</p>)
}


</div>

</div>

</div>


    );
  }
export default Upload;