class Driver{
    constructor(points,directions,div,listdivs){
        this.points = points;
        this.directions = directions;
        this.div = div;
        this.listdivs = listdivs;
    }
}

class Customer{
    constructor(start,end,id){
        this.start = start;
        this.end = end;
        this.id = id;
    }
}

container = document.getElementById("container");
var containerWidth = container.style.width || getComputedStyle(container).width;
var containerWidth = container.style.height || getComputedStyle(container).height;

activated = true;
speed = 10;

drivers = []

function topPlusOne(element,driver){
    
    // trajet
    currentTop = parseFloat(driver.listdivs[0].style.top);

    let newTop = currentTop + 0.1;
    driver.listdivs[0].style.top = `${newTop}%`;

    currentHeight = parseFloat(driver.listdivs[0].style.height);
    let newHeight = Math.max(currentHeight - 0.1,0);
    driver.listdivs[0].style.height = `${newHeight}%`;
    if (currentHeight <= 0){
        driver.listdivs.shift();
        driver.directions.shift();
    }
    element.style.top = `calc(${newTop}% - 7.5px`;
}
function topMinusOne(element,driver){
    // trajet
    currentTop = parseFloat(driver.listdivs[0].style.top) + parseFloat(driver.listdivs[0].style.height);

    let newTop = currentTop - 0.1;
    currentHeight = parseFloat(driver.listdivs[0].style.height);

    let newHeight = Math.max(currentHeight - 0.1,0);
    driver.listdivs[0].style.height = `${newHeight}%`;
    if (currentHeight <= 0){
        driver.listdivs.shift();
        driver.directions.shift();
    }
    element.style.top = `calc(${newTop}% - 7.5px`;
    
}
function leftPlusOne(element,driver){
    currentLeft = parseFloat(driver.listdivs[0].style.left);

    let newLeft = currentLeft + 0.1;
    driver.listdivs[0].style.left = `${newLeft}%`;

    currentWidth = parseFloat(driver.listdivs[0].style.width);

    let newWidth = Math.max(currentWidth - 0.1,0);
    driver.listdivs[0].style.width = `${newWidth}%`;
    if (currentWidth <= 0){
        driver.listdivs.shift();
        driver.directions.shift();
    }
    element.style.left = `calc(${newLeft}% - 7.5px`;
}
function leftMinusOne(element,driver){
    // trajet
    currentLeft = parseFloat(driver.listdivs[0].style.left) + parseFloat(driver.listdivs[0].style.width);

    let newLeft = currentLeft - 0.1;
    currentWidth = parseFloat(driver.listdivs[0].style.width);

    let newWidth = Math.max(currentWidth - 0.1,0);
    driver.listdivs[0].style.width = `${newWidth}%`;
    if (currentWidth <= 0){
        driver.listdivs.shift();
        driver.directions.shift();
    }
    element.style.left = `calc(${newLeft}% - 7.5px`;
}

function move(driver){
    console.log("SIU")
    if (driver.directions == []){

    }
    else if (driver.directions[0] == 1){
        leftPlusOne(driver.div,driver);
    }
    else if (driver.directions[0] == -1){
        leftMinusOne(driver.div,driver);
    }
    else if (driver.directions[0] == 2){
        topPlusOne(driver.div,driver);
    }
    else{
        topMinusOne(driver.div,driver);
    }
}

function request(start,end,customer){
    displayCustomer(start[0],start[1],id);
}

function genTraject(start,end,driver){
    nbsubdivs = 30;
    arrx = [start[0],end[0]];
    arry = [start[1],end[1]];
    for (i = 1; i < Math.min(Math.abs(end[0] - start[0]),Math.abs(end[1] - start[1]))*nbsubdivs/100; i++){
        if (Math.random() < 0.5){
            arrx.push(start[0] + (end[0]-start[0])*(0.1 + Math.random()*0.8));
            arry.push(start[1] + (end[1]-start[1])*(0.1 + Math.random()*0.8));
        }
    }

    arrx.sort(function(a,b){
        if (start[0] < end[0]){
            return a-b;
        }
        return b-a;
    });
    arry.sort(function(a,b){
        if (start[1] < end[1]){
            return a-b;
        }
        return b-a;
    });
    for (i = 0; i < arrx.length; i++){
        driver.points.push([arrx[i],arry[i]])
    }

    for (i=0; i < arrx.length - 1; i++){
        mult1 = 0;
        mult2 = 0;
        dir = "h";
        if (Math.random() < 0.5){
            mult1 = 1;
            mult2 = 2;
            displayLHLine(driver.points[i],driver.points[i+1],driver,1);
        }
        else{
            dir = "v";
            mult1 = 2;
            mult2 = 1;
            displayLHLine(driver.points[i+1],driver.points[i],driver,-1);
        }

        if (start[0] - end[0] >= 0 && dir=="h"){
            mult1 *= -1;
        }
        if (start[1] - end[1] >= 0 && dir=="v"){
            mult1 *= -1;
        }
        if (start[0] - end[0] >= 0 && dir=="v"){
            mult2 *= -1;
        }
        if (start[1] - end[1] >= 0 && dir=="h"){
            mult2 *= -1;
        }
        driver.directions.push(mult1);
        driver.directions.push(mult2);
    }

    if (end[0] - start[0] < 0){
        console.log("HUHU",driver.listdivs);
        console.log("HUHU",driver.listdivs.reverse());
        driver.listdivs = driver.listdivs.reverse();
        console.log(["a","b","c"].reverse());
    }
}

function displayLHLine(start,end,driver,dir){
    console.log("HOHOHO")
    if (start[0] < end[0]){
        if (start[1] < end[1]){    
            div1 = displayHLine(start[0],start[1],end[0] - start[0]);
            div2 = displayVLine(end[0],start[1],end[1] - start[1]);
        }
        else {
            div1 = displayHLine(start[0],start[1],end[0] - start[0]);
            div2 = displayVLine(end[0],end[1],start[1] - end[1]);
        }
    }
    else {
        if (start[1] < end[1]){
            div1 = displayHLine(end[0],start[1],start[0] - end[0]);
            div2 = displayVLine(end[0],start[1],end[1] - start[1]);
        }
        else {
            div1 = displayHLine(end[0],start[1],start[0] - end[0]);
            div2 = displayVLine(end[0],end[1],start[1] - end[1]);
        }
    }
    if (dir == 1 && (end[1] - start[1])*(end[0] - start[0]) >= 0){
        driver.listdivs.push(div1);
        driver.listdivs.push(div2);
    }
    else if (dir == -1 && (end[1] - start[1])*(end[0] - start[0]) >= 0){
        driver.listdivs.push(div2);
        driver.listdivs.push(div1);
    }
    else if (dir == 1 && (end[1] - start[1])*(end[0] - start[0]) < 0){
        driver.listdivs.push(div1);
        driver.listdivs.push(div2);
    }
    else{
        driver.listdivs.push(div2);
        driver.listdivs.push(div1);
    }
}

function displayHLine(left,top,length){
    trajx = document.createElement("div");
    document.getElementById("container").appendChild(trajx);
    trajx.style.height = "2px"
    trajx.style.backgroundColor = "white";
    trajx.style.position = "absolute";
    trajx.style.left = left.toString() + "%";
    trajx.style.top = top.toString() + "%";
    trajx.style.width = length.toString() + "%";
    return trajx;
}

function displayVLine(left,top,length){
    trajy = document.createElement("div");
    document.getElementById("container").appendChild(trajy);
    trajy.style.width = "2px"
    trajy.style.backgroundColor = "white";
    trajy.style.position = "absolute";
    trajy.style.left = left.toString() + "%";
    trajy.style.top = top.toString() + "%";
    trajy.style.height = length.toString() + "%";
    return trajy;
}

function displayCustomer(left,top,id){
    newCustomer = document.createElement("div");
    newCustomer.id = "customer-" + id;
    document.getElementById("container").appendChild(newCustomer);
    newCustomer.style.borderRadius = "100%";
    newCustomer.style.borderColor = "white";
    newCustomer.style.borderStyle = "solid";
    newCustomer.style.borderWidth = "10px";
    newCustomer.style.position = "relative";
    newCustomer.style.float = "overlay";
    newCustomer.style.left = "calc(" + (10*left).toString() + "% - 5px)";
    newCustomer.style.top = "calc(" + (10*top).toString() + "% - 5px)";
    newCustomer.style.width = "0px";
    newCustomer.style.height = "0px";
}

function displayDriver(left,top,id){
    newDriver = document.createElement("div");
    newDriver.id = "driver-" + id;
    document.getElementById("container").appendChild(newDriver);
    newDriver.style.backgroundColor = "white";
    newDriver.style.position = "absolute";
    newDriver.style.left = "calc(" + left.toString() + "% - 7.5px)";
    newDriver.style.top = "calc(" + top.toString() + "% - 7.5px)";
    newDriver.style.width = "15px";
    newDriver.style.height = "15px";
    return newDriver;
}

speedel = document.getElementById("speed");
speedel.addEventListener('input',function(){
    speed = speedel.value;
    startInterval();
})


driver = new Driver([],[],displayDriver(15,20,5),[]);
genTraject([15,20],[70,80],driver);
drivers.push(driver);

console.log(driver.directions);
console.log(driver.listdivs)


var interval = 0;
function startInterval(){
    console.log("HOHF");
    if (speed != 0){
        console.log("CU");
        if (!interval){
            interval = setInterval(function(){
                if (speed){
                    for (i=0; i < drivers.length; i++){
                        move(drivers[i]);
                    }
                }
            },500/speed);
        }
        else{
            clearInterval(interval);
            interval = setInterval(function(){
                if (speed){
                    for (i=0; i < drivers.length; i++){
                        move(drivers[i]);
                    }
                }
            },500/speed);
        }
    }
    else{
        console.log("HOHUHF");
        clearInterval(interval);
    }
}
