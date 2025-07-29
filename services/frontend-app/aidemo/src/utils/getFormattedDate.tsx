const getFormattedDate = (date: Date) => {
    //const formattedDate = "";

    let year, month, day, hour, minute: string = "";

    //2026-06-24 13:23:30
    year = date.getFullYear() +"-";
    //year = "2025" + "-";
    if (date.getMonth()<10)
    {
      month = "0"+ (date.getMonth()+1) +"-";  
    }
    else
    {
      month = (date.getMonth()+1) +"-";  
    }
    
    if (date.getDate()<10)
    {
      day = "0"+date.getDate() +" ";
    }
    else
    {
      day = ""+date.getDate() +" ";
    }

    if (date.getHours()<10)
    {
      hour = "0"+date.getHours() +":";
    }
    else
    {
      hour = ""+date.getHours() +":";
    }

    if (date.getMinutes()<10)
      {
        minute = "0"+date.getMinutes() +":";
      }
      else
      {
        minute = ""+date.getMinutes() +":";
      }

  const formattedDate = year.concat(month,day, hour,minute,"00");
    return formattedDate;

  }

  export default getFormattedDate;
