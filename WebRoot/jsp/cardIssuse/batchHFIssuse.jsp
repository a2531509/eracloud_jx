<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function() {
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				toquery();
			}
		});
		$("#synGroupIdTip").tooltip({
			position:"top",    
			content:"<span style='color:#B94A48'>是否发送老卡注销信息到社保</span>" 
		});
		$("#sync2Sb").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否"
		});
		$.autoComplete({
			id:"madeCardTaskNo",
			text:"task_id",
			value:"task_name",
			table:"card_apply_task",
			keyColumn:"task_id",
			optimize:true,
			minLength:"1"
		},"madeCardTaskName");
		$.autoComplete({
			id:"madeCardTaskName",
			text:"task_name",
			value:"task_id",
			table:"card_apply_task",
			keyColumn:"task_name",
			optimize:true,
			minLength:"1"
		},"madeCardTaskNo");
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YJS%>,<%=com.erp.util.Constants.TASK_STATE_FFZ%>,<%=com.erp.util.Constants.TASK_STATE_FFWC%>",
			isShowDefaultOption:true
		});
		createRegionSelect(
			{id:"regionId",editable:false},
			{id:"townId",editable:false},
			{id:"commId",editable:false}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:["<%=com.erp.util.Constants.CARD_TYPE_SMZK%>","<%=com.erp.util.Constants.CARD_TYPE_QGN%>"],
			isShowDefaultOption:true
		});
		createSysBranch({
			id:"brchId"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardIssuse/cardIssuseAction!cardBatchIssuseQuery.action",
			pagination:true,
			border:false,
			fitColumns:true,
			scrollbarSize:0,
			pageList:[100,200,500,1000,2000],
			singleSelect:true,
			showFooter:true,
			singleSelect:false,
			frozenColumns:[[
	            {field:"SETTLEID",title:"id",checkbox:true},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:"150px"},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:"80px"},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width:"200px"},
				{field:"TASK_STATE",title:"任务状态",sortable:true,width:"80px"}
			]],
			columns:[[
				{field:"TASK_WAY",title:"任务组织方式",sortable:true},
				{field:"TASK_DATE",title:"任务时间",sortable:true},
				{field:"CARD_TYPE",title:"卡类型",sortable:true},
				{field:"IS_URGENT",title:"制卡方式",sortable:true},
				{field:"TASK_SUM",title:"任务数量",sortable:true},
				{field:"IS_BATCH_HF",title:"批量换发",sortable:true, formatter:function(v){
					if(v == "0"){
						return "是";
					} else {
						return "否";
					}
				}},
				{field:"NOTE",title:"备注",formatter:function(v, r){
					if(r.CARD_TYPE2 == <%=Constants.CARD_TYPE_SMZK%>){
						var taskSum = Number(r.TASK_SUM);
						var endNum = isNaN(r.END_NUM)?0:Number(r.END_NUM);
						var yhNum = isNaN(r.YH_NUM)?0:Number(r.YH_NUM);
						return "成功制卡 " + endNum + " 张，银行审核不通过 " + (taskSum - yhNum) + " 张";
					}
				}}
			]],
			onLoadSuccess:function(data){
        	    if(data.status != 0){
        		    $.messager.alert("系统消息",data.errMsg,"error");
        		    return;
        	    }
        	    updateFooter();
			},
			onSelect:function(){
				updateFooter();
			},
			onUnselect:function(){
				updateFooter();
			},
			onSelectAll:function(){
				updateFooter();
			},
			onUnelectAll:function(){
				updateFooter();
			}
		});
		$.addNumber("agtTelNo");
		$.addNumber("corpId");
	});
	
	function updateFooter(){
		var sum = 0;
		var cnt = 0;
		var selection = $("#dg").datagrid("getSelections");
		if(selection){
			for(var i in selection){
				cnt++;
				sum += isNaN(selection[i].TASK_SUM)?0:Number(selection[i].TASK_SUM);
			}
		}
		
		$("#dg").datagrid("reloadFooter", [{TASK_ID:"统计：", MAKE_BATCH_ID:"共 " + cnt + " 个任务", TASK_SUM : "共 " + sum + " 个人"}]);
	}
	
	function toquery(){
		$("#agtinfo").form("reset");
		var options = getformdata("searchConts");
		options["queryType"] = "0";
		options["corpName"] = $("#corpName").val();
		options["taskStartDate"] = $("#taskStartDate").val();
		options["taskEndDate"] = $("#taskEndDate").val();
		options["isBatchHf"] = "0";
		$grid.datagrid("load",options);
	}
	function toviewtask(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.modalDialog({
				title:"任务明细预览",
				fit:true,
				maximized:true,
				closable:false,
				iconCls:"icon-viewInfo",
				href:"jsp/cardIssuse/viewCardIssuse.jsp?taskId=" + rows[0].TASK_ID,
				tools:[{
					text:"关闭",iconCls:"icon-cancel",
					handler:function() {
						$.modalDialog.handler.dialog("destroy");
					    $.modalDialog.handler = undefined;
					}
				}]
			});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行预览","warning");
		}
	}
	function tosaveinfo(){
	    var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(!rows || rows.length == 0){
			$.messager.alert("系统消息","请勾选一条任务记录进行发放","error");
			return;
		}
		for(var d = 0;d < rows.length;d++){
			taskIds = taskIds + rows[d].TASK_ID + ",";
		}
		if(dealNull(taskIds).length <= 0){
			$.messager.alert("系统消息","请勾选一条任务记录进行发放","error");
			return;
		}
		taskIds = taskIds.substring(0,taskIds.length - 1);
		$.messager.confirm("系统消息","您确定要批量发放所勾选的制卡任务吗？",function(r){
     	    if (r){
     			$.messager.progress({text:"数据处理中，请稍后...."});
     			var params = getformdata("agtinfo");
     			params["taskIds"]  = taskIds;
     			params["issuseType"] = "0";
     			params["rec.agtName"] = $("#agtName").val();
     			params["sync2Sb"]  = $("#sync2Sb").prop("checked");
     			params["isBatchHf"] = "0";
  				$.post("cardIssuse/cardIssuseAction!saveBatchCardIssuse.action", params, function(data,status){
	  		        $.messager.progress("close");
	  		      	if(data.status == "0"){
	  		      		$.messager.alert("系统消息",data.errMsg,"info",function(){
		  		      		var dealNos = data.dealNos.split(",");
		  		      		for(var index = 0; index < dealNos.length; index++) {
		  		      		    showReport("规模发放", dealNos[index]);
		  		      		}
		 		     		$grid.datagrid("reload");
		 		     		$("#agtinfo").form("reset");
	  		      		});
	 		     	}else if(data.sucNums <= 0){
		     			$.messager.alert("系统消息",data.errMsg,"error");
		     		}else{
		     			$.messager.alert("系统消息",data.errMsg,"info");
		     			$grid.datagrid("reload");
		     			$("#agtinfo").form("reset");
		     		}
			 	},"json");
     		}
		});
	}
	function autoCom(){
		if($("#corpId").val() == ""){
			$("#corpName").val("");
		}
		$("#corpId").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#corpId"},
		    source: function(request,response){
			    $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#corpId").val()},function(data){
			    	response($.map(data,function(item){return {label:item.text,value:item.value};}));
			    });
		    },
		    select: function(event,ui){
		      	$("#corpId").val(ui.item.label);
		        $("#corpName").val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
	      		$("#corpId").val(ui.item.label);
		        $("#corpName").val(ui.item.value);
		        return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#corpName").val() == ""){
			$("#corpId").val("");
		}
		$("#corpName").autocomplete({
		    source:function(request,response){
		        $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#corpName").val(),"queryType":"0"},function(data){
		            response($.map(data,function(item){return {label:item.value,value:item.text};}));
		        });
		    },
		    select: function(event,ui){
		      	$("#corpId").val(ui.item.value);
		        $("#corpName").val(ui.item.label);
		        return false;
		    },
		    focus: function(event,ui){
		        return false;
		    }
	    }); 
	}
	function readIdCard2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<n:initpage title="批量换发任务进行批量发放操作！">
	<n:center>
		<div id="tb" >
			<form id="searchConts">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:7%">网点：</td>
						<td class="tableright"><input id="brchId" name="brchId" type="text" class="textinput" /></td>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="madeCardBatchNo" name="madeCardBatchNo" type="text" class="textinput" /></td>
						<td class="tableleft">任务编号：</td>
						<td class="tableright"><input id="madeCardTaskNo" name="madeCardTaskNo" type="text" class="textinput" /></td>
						<td class="tableleft">任务名称：</td>
						<td class="tableright"><input id="madeCardTaskName" name="madeCardTaskName" type="text" class="textinput" /></td>
					</tr>
					<tr>
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input name="corpId"  class="textinput" id="corpId" type="text" onkeydown="autoCom()" onkeyup="autoCom()" maxlength="15"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input name="corpName"  class="textinput" id="corpName" type="text" onkeydown="autoComByName()" onkeyup="autoComByName()" maxlength="50"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="cardType" type="text"  class="easyui-combobox"  style="width:174px;"/></td>
						<td class="tableleft">所在城区：</td>
						<td class="tableright"><input id="regionId" name="regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">乡镇（街道）：</td>
						<td class="tableright"><input id="townId" name="townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区（村）：</td>
						<td class="tableright"><input name="commId" class="textinput" id="commId" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="taskState" type="text" class="easyui-combobox" style="width:174px;"/></td>
						<td colspan="6" class="tableleft" style="padding-right: 2%">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false" onclick="toquery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false" onclick="toviewtask();">预览</a>
							<shiro:hasPermission name="toBatchSave">
								&nbsp;
								<span id="synGroupIdTip">
									<input id="sync2Sb" name="sync2Sb" type="checkbox">
								</span>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ok"  plain="false" onclick="tosaveinfo();">确定</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="制卡任务信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:100px;border-left:none;border-bottom:none;overflow:hidden;">
		<div class="datagrid-toolbar" style="height:100%;">
			<form id="agtinfo">
				<h3 class="subtitle">代理人信息</h3>
				<table class="tablegrid" style="width:100%">
					<tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox" value="1"/> </td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" validtype="idcard" maxlength="18"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input id="agtName"  name="rec.agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
						<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input id="agtTelNo" name="rec.agtTelNo" type="text" class="textinput easyui-validatebox" maxlength="11" validtype="mobile"/></td>
					</tr>
					<tr>
						<td class="tableleft" colspan="8" style="text-align: center;">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</div>
</n:initpage>