import fs from 'fs';
import { StringUtils } from 'turbocommons-ts';
import { parse } from 'csv-parse';
import * as path from "path";
//import * as IPFS from 'ipfs-core';
import * as IPFS from 'ipfs-http-client';
const basePath = process.cwd();

async function getJsonAndImage() {
    const imageIpfsPath: any = "QmSKkAK7X3nbDBEh84r1WLLhFR9RkUjqPHSoXcWSVdYwUz";
        //BaseURI to concatenate with image CID to add to json file
        const baseURI: string = "https://ipfs.io/ipfs/"
        let imageURI = new Array<string>(3000);
        let cid: any;
        const ipfs = await IPFS.create();
        console.log(ipfs);
        for await(const file of ipfs.ls(imageIpfsPath)) {
            console.log(file);
        }
}

async function getNftImageUri() {
    console.log("Getting First CID");
    let i: number = 0;
    let index: string = '';
    let indexTemp: Array<string> = [];
    let indexInt: number;
    //let inputAddr: URL = new URL('http://127.0.0.1:8080');
    //Image folder path - concatenate "/number.png" for individual image
    const imageIpfsPath: any = "QmPUyo5A5hNur2SS5Yfj2yvdWoRoRCSbQ3PxX4dG9ivwPL";
    //BaseURI to concatenate with image CID to add to json file
    const baseURI: string = "https://ipfs.io/ipfs/"
    let imageURI = new Array<string>(3000);
    let cid: any;
    const ipfs = IPFS.create();
    //ipfs.pubsub.setMaxListener(0);
    //Get the CID of each image and store the final URI in the imageURI array
    for await(const file of ipfs.ls(imageIpfsPath)) {
        cid = file.cid.toString();
        index = file.name;
        indexTemp = index.split('.');
        index = indexTemp[0];
        console.log(index);
        indexInt = parseInt(index, 10);
        imageURI[indexInt-1] = baseURI + cid;
        console.log("CID " + indexInt + ": " + imageURI[indexInt-1]);
    }
    return imageURI;
}

type ClownBio = {
    Name: string;
    Bio: string;
    Age: string;
    NetWorth: string;
    CauseOfDeath: string;
}

type MetadataStructure = {
    name: string;
    bio: string;
    age: string;
    networth: string;
    causeofdeath: string;
    description: string;
}

function grabNameandDescription(index: number): MetadataStructure {
    let clownName: string = "";
    let rawdata: any;
    //let textPath: string = path.resolve(__dirname, "./extras/clownBios.csv");
    let textPath: string = "./extras/clownBios.csv";
    console.log(textPath);
    const headers = ['Name', 'Bio', 'Age', 'Net Worth', 'Cause of Death'];
    let realIndex: number = index;
    let clownNameArray: string = "";
    let clownDescriptionArray: string = "";
    rawdata = fs.readFileSync(textPath, 'utf8');
    parse(rawdata, {
        delimiter: ',',
        columns: headers,
    }, (error, result: ClownBio[]) => {
        if(error) {
            console.log(error);
        }
        console.log(result[index]);
    })
    return {
        name: clownNameArray,
        bio: "",
        age: "",
        networth: "",
        causeofdeath: "",
        description: clownDescriptionArray
    };
}


async function updateNftJson() {

    let rawdata: any;
    let data: any;
    const baseJsonPath: string = "./jsonOutput/";
    let jsonInPath: string = "";
    let jsonOutPath: string = "";
    let clownName: string = "";
    let pussySubClan: string = "";
    let pussyClan: string = "";

    for(let i = 1; i < 2; i ++) {
        //console.log("Loop: " + i);
        jsonInPath = baseJsonPath + i + '.json';
        //jsonInPath = path.resolve(__dirname, baseJsonPath + i + '.json');
        console.log(jsonInPath);
        rawdata = fs.readFileSync(jsonInPath);
        data = JSON.parse(rawdata);
        try {
            data.attributes.forEach((item: any) => {
                let tempString = item.value;
                let tempStringSplit = tempString.split(/(?=[A-Z])/);
                item.value = tempStringSplit[1];
            });
        } catch(error) {
            console.log(error);
        }
        try {
            let metadataUpdate: MetadataStructure = grabNameandDescription(i);
            clownName = metadataUpdate.name; //= StringUtils.formatCase(grabName(i), StringUtils.FORMAT_START_CASE);
            clownName = clownName.replace(/(\r\n|\n|\r)/gm, "");
            data.name = clownName;
            data.bio = metadataUpdate.bio;
            data.age = metadataUpdate.age;
            data.networth = metadataUpdate.networth;
            data.causeofdeath = metadataUpdate.causeofdeath
            data.description = ``;
            //data.image = "https://gateway.pinata.cloud/ipfs/QmV4dQTYM5B6aaNyKkJ2r7WyQRTh3gFT72V38m8akhykq3/" + i + ".png";
            data.edition = i;
            fs.writeFileSync(
                `test/${data.edition}.json`,
                JSON.stringify(data, null, 2)
            );
        } catch(error) {
            console.log(error);
        }
    }


}

updateNftJson();
//getJsonAndImage();