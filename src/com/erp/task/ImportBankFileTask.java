package com.erp.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.erp.service.TaskManagementService;

@Component("importBankFileTask")
public class ImportBankFileTask {

	@Autowired
	private TaskManagementService taskManagementService;

	public void execute() {
		taskManagementService.saveImportTaskRhFileAuto();
	}
}
