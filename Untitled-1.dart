import { BigInt } from "@graphprotocol/graph-ts";

import {
  kcloud,
  DrumInTransit,
  DrumPackaged,
  GPSDataEvent,
  NewDrumEnrolled,
  SensorDataEvent,
  SensorDataEvent2,
  TakingOver,
  TemporaryStorage,
  sensorToDrumPairingEvent,
} from "../generated/kcloud/kcloud";
import {
  Drum,
  Sensor,
  DrumHistory,
  InTransitData,
  PackagingData,
  TemporaryStorageData,
  TakingOverData,
  SensorData,
} from "../generated/schema";


export function handleGPSDataEvent(event: GPSDataEvent): void { }

export function handleNewDrumEnrolled(event: NewDrumEnrolled): void {
  let new_drum = new Drum(event.params.drum_id.toString());
  let new_sensor = new Sensor(event.params.sensor_id.toString());
  new_drum.sensor = new_sensor.id;
  new_sensor.drum = new_drum.id;
  let drumHistory = new DrumHistory(event.params.drum_id.toString());
  drumHistory.drum = new_drum.id;
  new_drum.currentStatus = "Enrolled";

  new_drum.save();
  new_sensor.save();
  drumHistory.save();
}

export function handleDrumPackaged(event: DrumPackaged): void {
  let my_drum = Drum.load(event.params.drum_id.toString());

  if (my_drum) {
    let drumHistory = DrumHistory.load(event.params.drum_id.toString());
    if (drumHistory == null) {
      drumHistory = new DrumHistory(event.params.drum_id.toString());
    }
    if (drumHistory) {
      drumHistory.drum = my_drum.id;
      my_drum.classification = event.params.classification;
      my_drum.type = event.params.w_type;
      my_drum.date_unix = event.params.date_unix;
      my_drum.place_of_occurence = event.params.place_of_occurence;
      my_drum.currentStatus = "Packaged";
      my_drum.radioactive_concentration = event.params.radioactive_concentration;
      my_drum.pollution_level = event.params.pollution_level;
      my_drum.wasteAcceptanceRequest = event.params.waste_acceptance_request;
      let packagingData = new PackagingData(event.params.drum_id.toString());
      drumHistory.packagingData = packagingData.id;
      packagingData.wasteAcceptanceRequest = my_drum.wasteAcceptanceRequest;
      packagingData.classification = my_drum.classification;
      packagingData.type = my_drum.type;
      packagingData.date_unix = my_drum.date_unix;
      packagingData.place_of_occurence = my_drum.place_of_occurence;
      packagingData.radioactive_concentration = my_drum.radioactive_concentration;
      packagingData.pollution_level = my_drum.pollution_level;
      my_drum.save();
      packagingData.save();
      drumHistory.save();
    }
  }
}

export function handleDrumInTransit(event: DrumInTransit): void {
  let my_drum = Drum.load(event.params.drum_id.toString());

  if (my_drum) {
    let drumHistory = DrumHistory.load(event.params.drum_id.toString());
    if (drumHistory == null) {
      drumHistory = new DrumHistory(event.params.drum_id.toString());
    }
    drumHistory.drum = my_drum.id;

    my_drum.currentStatus = "In Transit";

    let inTransitData = new InTransitData(event.params.drum_id.toString());
    drumHistory.inTransitData = inTransitData.id;

    inTransitData.date_unix = event.params.time;
    inTransitData.carrier = event.params.carrier;
    inTransitData.transportation_schedule =
      event.params.transportation_schedule;
    //inTransitData.status = event.params.;
    drumHistory.inTransitData = inTransitData.id;
    drumHistory.save();
    inTransitData.save();
    my_drum.save();
  }
}

export function handleTakingOver(event: TakingOver): void {
  let my_drum = Drum.load(event.params.drum_id.toString());

  if (my_drum) {
    let drumHistory = DrumHistory.load(event.params.drum_id.toString());
    if (drumHistory == null) {
      drumHistory = new DrumHistory(event.params.drum_id.toString());
    }
    drumHistory.drum = my_drum.id;

    my_drum.currentStatus = "Taken Over";
    my_drum.wasteAcceptanceRequest = event.params.waste_acceptance_request;
    let takingOverData = new TakingOverData(event.params.drum_id.toString());
    drumHistory.takingOverData = takingOverData.id;

    takingOverData.date_unix = event.params.time;
    takingOverData.acquisition = event.params.acquisition;
    takingOverData.transferee = event.params.transferee;
    takingOverData.transportation_schedule =
      event.params.transportation_schedule;
    takingOverData.wasteAcceptanceRequest =
      event.params.waste_acceptance_request;
    //inTransitData.status = event.params.;
    drumHistory.takingOverData = takingOverData.id;

    my_drum.save();
    drumHistory.save();
    takingOverData.save();
  }
}
class Container {
  data: string | null
}

export function handleSensorDataEvent(event: SensorDataEvent): void {
  let sensorData = new SensorData(event.params.data_id.toString());
  let drum = Drum.load(event.params.drum_id.toString());
  // if (!sensor) {
  //   let sensor = new Sensor(event.params.sensor_id.toString());
  // }

  if (drum) {
      sensorData.drum = drum.id;
      let currentStatus = drum.currentStatus;
      sensorData.drum = drum.id;
      sensorData.currentStatus = currentStatus;
      drum.save();
  }
    
  sensorData.time_recorded = event.params.time;
  sensorData.GPS_longitude = event.params.longitude;
  sensorData.GPS_Latitude = event.params.latitude;
  sensorData.accX = event.params.accX;
  sensorData.save();
}

export function handleSensorDataEvent2(event: SensorDataEvent2): void {
  // emit SensorDataEvent(sensor_id, time, data_id, latitude, longitude, accX);
  // emit SensorDataEvent2(data_id, accZ, temp, humi, radio, alarm);
  let sensorData = SensorData.load(event.params.data_id.toString());
  if (sensorData) {
    sensorData.accZ = event.params.accZ;
    sensorData.temp = event.params.temp;
    sensorData.humidity = event.params.humi;
    sensorData.radio = event.params.radio;
    sensorData.alarm = event.params.alarm;
    sensorData.save();
  }
}

export function handleTemporaryStorage(event: TemporaryStorage): void {
  let my_drum = Drum.load(event.params.drum_id.toString());

  if (my_drum) {
    let drumHistory = DrumHistory.load(event.params.drum_id.toString());
    if (drumHistory == null) {
      drumHistory = new DrumHistory(event.params.drum_id.toString());
    }
    drumHistory.drum = my_drum.id;

    my_drum.currentStatus = "In Temporary Storage";

    let temporaryStorageData = new TemporaryStorageData(
      event.params.drum_id.toString()
    );
    drumHistory.temporaryStorageData = temporaryStorageData.id;
    temporaryStorageData.date_unix = event.params.time;
    temporaryStorageData.storage_id = event.params.storage_id;
    temporaryStorageData.longitude = event.params.longitude;
    temporaryStorageData.latitude = event.params.latitude;
    temporaryStorageData.storage_schedule = event.params.storage_schedule;

    //inTransitData.status = event.params.;
    drumHistory.temporaryStorageData = temporaryStorageData.id;

    my_drum.save();
    drumHistory.save();
    temporaryStorageData.save();
  }
}
export function handlesensorToDrumPairingEvent(event: sensorToDrumPairingEvent):  void{
    let my_drum = Drum.load(event.params.drum_id.toString());
    if (my_drum){
      
      my_drum.sensor = 
    }
}