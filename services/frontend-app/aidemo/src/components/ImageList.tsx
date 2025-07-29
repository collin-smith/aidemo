import 
{ useState  } from "react";
import * as Module from "../interfaces/Image";
import Modal from "./Modal";
import getConfigurationProperties from "../utils/getConfigurationProperties";



//Props Interface
interface ImageListProps { images: Module.Image[]  } 


const ImageList = ({ images}:ImageListProps) => {
  const configurationProperties = getConfigurationProperties();
  const [open, setOpen] = useState(false)
  const [modalBody, setModalBody] = useState<string>('')
  const [modalKey, setModalKey] = useState<string>('')
  const handleDelete = (event: React.MouseEvent<SVGSVGElement>) => {
  let id = event.currentTarget.id
  setModalBody("Do you really want to delete "+id+"?")
  setModalKey(id)
  setOpen(true);
  };


  //A Modal Property method to handle the return
  const handleModalSubmit = async (value: string) => {
   let deleteJson = '{ "Objects" : [ {"Key": "'+value+'"} ]}'
   let headers = new Headers();
   headers.append('Content-Type', 'application/json');

   let url = configurationProperties.baseUrl + "/prod/objects";

   const response2 = await fetch(url, {
        method: 'DELETE',
        headers: headers,
        body: JSON.stringify(deleteJson),
    });
 
    if (!response2.ok) {
      throw new Error(`HTTP error! status: ${response2.status}`);
    }
 
    //Let us find that file in the images and remove it
    let indexToRemove = -1
    for (let i = 0; ((i < images.length) && (indexToRemove==-1)); i++) {
      if (value == images[i].key)
      {
        indexToRemove = i
      }
    }
    if (indexToRemove>-1)
    {
      images.splice(indexToRemove,1)
    }  
    setOpen(false);
  };

  return (

<div className="grid grid-cols-4">
      {images.map(image => (
       <div key={image.url} className="border-2 border-gray-200">
          <div className="rounded bg-white-300 border-gray-200 "> 

                {image.url.endsWith(".pdf") ||image.url.endsWith(".txt")  ? (
            <a href={image.url} target="new">{image.url}</a>
            ) : (
            <img src={image.url} />
            )
          }
            <div className="m-1">
              <span className="font-bold">{image.key} <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 inline-block"  id={image.key} onClick={handleDelete}>
  <path strokeLinecap="round" strokeLinejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
</svg></span>

            </div>
          </div>
        </div>


      ))}

      <Modal title="Delete Image" body={modalBody} open={open} key1={modalKey} onSubmit={handleModalSubmit} setOpen={()=> setOpen(false)} ></Modal>

    </div>
  );
}
 
export default ImageList;