import React, { } from "react";

import { Label, Listbox, ListboxButton, ListboxOption, ListboxOptions } from '@headlessui/react'
import { ChevronUpDownIcon } from '@heroicons/react/16/solid'
import { CheckIcon } from '@heroicons/react/20/solid'
import * as Module from "../interfaces/DropdownOption";

type propTypes = {
  selected:Module.DropdownOption,
  options:Module.DropdownOption[],
  handleSelectChange: (index: number)=> void;
};


const Dropdown: React.FC<propTypes> = ({ selected, options,  handleSelectChange}) => {

 const handleInsideSelectChange = (option: Module.DropdownOption) => {
    //Find the right option
    let found = false
    let index = 0;
    //let returnValue:Module.DropdownOption = options[0]
    for (let i = 0; (!found && i < options.length); i++) {
        let currentOption:Module.DropdownOption = options[i]
        if (currentOption.label == (""+option)) {
            //returnValue = currentOption
            index = i
            found = true
        }
    }
    selected = options[index]
    //Pass the index selected back 
    handleSelectChange(index)

}






  return (

<Listbox value={selected} onChange={handleInsideSelectChange} >
      <Label className="block text-sm/6 font-medium text-gray-900"></Label>
      <div className="relative mt-2">
        <ListboxButton className="grid cursor-default grid-cols-1 rounded-md bg-white py-1.5 pr-2 pl-3 text-left text-gray-900 outline-1 -outline-offset-1 outline-gray-300 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6">
          <span className="col-start-1 row-start-1 flex items-center gap-3 pr-6">
            <span className="block truncate">{selected.label}</span>
          </span>
          <ChevronUpDownIcon
            aria-hidden="true"
            className="col-start-1 row-start-1 size-5 self-center justify-self-end text-gray-500 sm:size-4"
          />
        </ListboxButton>

        <ListboxOptions
          transition
          className="absolute z-10 mt-1 max-h-56 overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black/5 focus:outline-hidden data-leave:transition data-leave:duration-100 data-leave:ease-in data-closed:data-leave:opacity-0 sm:text-sm"
        >
          {options.map((option) => (
            <ListboxOption
              key={option.value}
              value={option.label}
              className="group relative cursor-default py-2 pr-9 pl-3 text-gray-900 select-none data-focus:bg-indigo-600 data-focus:text-white data-focus:outline-hidden"
            >
              <div className="flex items-center">

                <span className="ml-3 block truncate font-normal group-data-selected:font-semibold">{option.label}</span>
              </div>

              <span className="absolute inset-y-0 right-0 flex items-center pr-4 text-indigo-600 group-not-data-selected:hidden group-data-focus:text-white">
                <CheckIcon aria-hidden="true" className="size-5" />
              </span>
            </ListboxOption>
          ))}
        </ListboxOptions>
      </div>
    </Listbox>

  );
};

export default Dropdown;