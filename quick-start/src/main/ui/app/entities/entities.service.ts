import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';
import { ProjectService } from '../projects/projects.service';

import { Entity } from './entity.model';
import { Flow } from './flow.model';

@Injectable()
export class EntitiesService {
  constructor(
    private http: Http,
    private projectService: ProjectService
  ) {}

  getEntities() {
    return this.get(this.url('/entities/'));
  }

  getEntity(entityName: string) {
    return this.get(this.url(`/entities/${entityName}`));
  }

  createEntity(entity: Entity) {
    return this.post(this.url('/entities/'), entity);
  }

  createFlow(entity: Entity, flowType: string, flow: Flow) {
    return this.post(this.url(`/entities/${entity.entityName}/flows/${flowType}`), flow);
  }

  getInputFlowOptions(flow: Flow) {
    const url = this.url(`/entities/${flow.entityName}/flows/input/${flow.flowName}/run`);
    return this.get(url);
  }

  saveInputFlowOptions(flow: Flow, mlcpOptions: any) {
    const url = this.url(
      `/entities/${flow.entityName}/flows/input/${flow.flowName}/save-input-options`);
    return this.http.post(url, mlcpOptions);
  }

  runInputFlow(flow: Flow, mlcpOptions: any) {
    const url = this.url(`/entities/${flow.entityName}/flows/input/${flow.flowName}/run`);
    return this.http.post(url, mlcpOptions).subscribe(() => {});
  }

  runHarmonizeFlow(flow: Flow, batchSize: number, threadCount: number) {
    const url = this.url(`/entities/${flow.entityName}/flows/harmonize/${flow.flowName}/run`);
    return this.http.post(url, { batchSize: batchSize, threadCount: threadCount }).subscribe(() => {});
  }

  public extractData = (res: Response) => {
    return res.json();
  }

  private get(url: string) {
    return this.http.get(url).map(this.extractData);
  }

  private post(url: string, data: any) {
    return this.http.post(url, data).map(this.extractData);
  }

  private url(u: string): string {
    return `/api/current-project${u}`;
  }
}
