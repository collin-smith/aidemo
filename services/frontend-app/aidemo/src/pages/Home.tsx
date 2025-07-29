import React, { } from 'react';
import '../index.css';


export interface IHomeProps {}

//const Home: React.FunctionComponent<IHomeProps> = () => {
const Home: React.FunctionComponent<IHomeProps> = () => {


    return (
    <div>
      <p className="text-left">Welcome to our AWS AI Demo Application</p>

<div className="flex flex-row gap-2">
Please check out the <span className="font-bold">Gallery</span>(to view objects) and the <span className="font-bold">Upload</span>(to upload objects) pages.
</div>

<div className="flex flex-row gap-2">
Please check out the <span className="font-bold">Services</span>(to explore AI functionality).
</div>
    </div>
    );
  }
export default Home;