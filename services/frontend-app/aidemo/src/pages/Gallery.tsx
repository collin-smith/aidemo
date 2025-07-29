import React, { } from 'react';
import '../index.css';
//import getConfigurationProperties from '../utils/getConfigurationProperties';
import useFetch from "../hooks/useFetch";
import ImageList from "../components/ImageList";

//import * as Interface from "../interfaces/Image";



//Props Interface
//interface ImageListProps { images: Interface.Image[]  } 

export interface IHomeProps {}

//const Home: React.FunctionComponent<IHomeProps> = () => {
const Gallery: React.FunctionComponent<IHomeProps> = () => {

 const restURL = '/prod/objects';
    
  //Original
  const { data: objects , error, isPending } = useFetch(restURL);
 
    return (
    <div>
      <p className="font-bold text-left">Gallery</p>
      { error && <div>{ error }</div> }
      { isPending && <div>Loading...</div> }
      { objects && <ImageList images={objects} /> }

    </div>
    );
  }
export default Gallery;