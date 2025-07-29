
import {  useState} from 'react';
import { useOutsideClick } from './useOutsideClick';

const Navigation = () => {
  const [burgerOpen, setBurgerOpen] = useState(false);
 // const burger = document.querySelector('#burger');
  const menu = document.querySelector('#menu');


  const ref = useOutsideClick(() => {
    //console.log('Clicked outside of MyComponent');
    setSelectDropDownOpen(false)
  });





if (burgerOpen) {menu?.classList.remove('hidden');}
if (!burgerOpen) {menu?.classList.add('hidden');}


  const [selectDropDownOpen, setSelectDropDownOpen] = useState(false);
//  const location = useLocation();
  //console.log("current URL="+location.pathname+"=");


  const selectdd = document.querySelector('#selectOptions');
 // console.log("selectDropDownOpen="+selectDropDownOpen);
 if (selectDropDownOpen) {selectdd?.classList.remove('hidden');}
  if (!selectDropDownOpen) {selectdd?.classList.add('hidden');}
  
    return (
<div ref={ref} className="navbar-background rounded">
<nav className="">
  <div className="container mx-auto px-4 md:flex items-center gap-6">
    {/* Logo  bg-sky-600 text-white*/}
    <div className="flex items-center justify-between md:w-auto w-full">
      <a href="/" className="py-5 px-2 flex-1 font-bold">AWS AI Demo</a>
      {/* mobile menu icon */}
      <div className="md:hidden flex items-center">
        <button type="button" className="mobile-menu-button" id="burger" onClick={()=>setBurgerOpen(!burgerOpen)}>
        <svg className="w-6 h-6" fill="none" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" stroke="currentColor" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"></path></svg>
        </button>
      </div>
    </div>

    <div className="hidden md:flex md:flex-row flex-col items-center justify-start md:space-x-1 pb-3 md:pb-0 navigation-menu" id="menu">
      <a href="/" className="nav-menuitem">Home</a>
      <a href="/gallery" className="nav-menuitem">Gallery</a>
      <a href="/upload" className="nav-menuitem">Upload</a>
      {/* Dropdown menu */}
      <div className="relative">
        <button type="button" className="dropdown-toggle py-2 px-3 nav-dropdown flex items-center gap-2 rounded" onClick={()=>setSelectDropDownOpen(!selectDropDownOpen)}>
          <span className="pointer-events-none select-none nav-dropdown">Services</span>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="size-6">
  <path strokeLinecap="round" strokeLinejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
</svg>
        </button>
        <div className="dropdown-menu absolute hidden bg-secondarybg text-secondarytext rounded-b-lg pb-2 w-40 z-50" id="selectOptions">
          <a href="/promptengineering" className="nav-dropdownitem">Prompt Engineering</a>
          <a href="/imagegeneration" className="nav-dropdownitem">Image Generation</a>
          <a href="/imageanalysis" className="nav-dropdownitem">Image Analysis</a>
          <a href="/documentanalysisllm" className="nav-dropdownitem">PDF Document Analysis</a>
          <a href="/documentanalysis" className="nav-dropdownitem">PDF Document Analysis (With Textract)</a>
        </div>
      </div>
    </div>
  </div>
</nav>

</div>
    );
  }
   
  export default Navigation;