<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="/layout/initpage.jsp" %>
<%-- 卡片回收登记 --%>
<script type="text/javascript">
	var $cardRecoverRegisterDataGrid;
	$(function(){
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"1"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
		}, "name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		}, "certNo");
		createSysBranch(
			{id:"recoverBranch"}
		);
		createLocalDataSelect({
			id:"recoverStatus",
			data:[
				{value:"", text:"请选择"},
				{value:"1", text:"已发放"},
				{value:"0", text:"已回收"}
			]
		});
		$cardRecoverRegisterDataGrid = createDataGrid({
			id:"cardRecoverRegisterDataGrid",
			singleSelect:true,
			url:"cardRecoverRegister/cardRecoverRegisterAction!queryCardRecoverRegisterInfo.action",
			pageSize:20,
			frozenColumns:[[
				{field:"ID",checkbox:true},
				{field:"DEAL_NO",title:"流水号",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"BOX_NO",title:"盒号",align:"center",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"NAME",title:"姓名",align:"center",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"SEX",title:"性别",align:"center",sortable:true,hidden:true,width:parseInt($(this).width() * 0.04)},
				{field:"CERT_TYPE", title:"证件类型",align:"center",sortable:true,hidden:true,width:parseInt($(this).width() * 0.06)},
				{field:"CERT_NO",title:"证件号码",align:"center",sortable:true,width:parseInt($(this).width() * 0.13)},
				{field:"CARD_NO",title:"卡号",align:"center",sortable:true,width:parseInt($(this).width() * 0.13)},
				{field:"CARD_TYPE",title:"卡类型",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"RECOVER_STATUS",title:"回收状态",align:"center",sortable:true, 
					formatter:function(value, row, index) {
						if (value == "0") {
							return "已回收";
						} else if (value == "1") {
							return "<span style='color:red'>已发放</span>";
						}
					}
				}
			]],
			columns:[[
				{field:"REC_BRANCH",title:"回收网点",align:"center",sortable:true},
				{field:"REC_USER",title:"回收柜员",align:"center",sortable:true},
				{field:"REC_DATE",title:"回收时间",align:"center",sortable:true},
				{field:"RE_ISSUE_BRANCH",title:"重新发放网点",align:"center",sortable:true},
				{field:"RE_ISSUE_USER",title:"重新发放柜员",align:"center",sortable:true},
				{field:"RE_ISSUE_DATE",title:"重新发放时间",align:"center",sortable:true},
				{field:"APPLY_WAY",title:"申领方式",align:"center",sortable:true},
				{field:"APPLY_TYPE",title:"申领类型",align:"center",sortable:true},
				{field:"APPLY_BRANCH",title:"申领网点",align:"center",sortable:true},
				{field:"APPLY_USER",title:"申领柜员",align:"center",sortable:true},
				{field:"APPLY_DATE",title:"申领时间",align:"center",sortable:true},
				{field:"ISSUE_BRANCH",title:"发放网点",align:"center",sortable:true},
				{field:"ISSUE_USER",title:"发放柜员",align:"center",sortable:true},
				{field:"ISSUE_DATE",title:"发放时间",align:"center",sortable:true},
				{field:"REGION_NAME",title:"区域",align:"center",sortable:true},
				{field:"TOWN_NAME",title:"乡镇（街道）",align:"center",sortable:true},
				{field:"COMMUNITY_NAME",title:"社区（村）",align:"center",sortable:true},
				{field:"CORP_ID",title:"单位编号",align:"center",sortable:true},
				{field:"CORP_NAME",title:"单位名称",align:"center",sortable:true}
			]]
		});
	});
	function query(){
		if ($("#recoverBeginDate").val() != "" && $("#recoverEndDate").val() != "") {
			var begin = new Date($("#recoverBeginDate").val().replace(/-/g,"/"));
			var end = new Date($("#recoverEndDate").val().replace(/-/g,"/"));
			if(begin - end > 0){
				jAlert("起始日期不能大于结束日期！");
				return;
			}
		}
		$cardRecoverRegisterDataGrid.datagrid("load",{
			"queryType":"0",
			"certNo":$("#certNo").val(),
			"name":$("#name").val(),
			"cardNo":$("#cardNo").val(),
			"boxNo":$("#boxNo").val(),
			"recoverBranch":$("#recoverBranch").combobox("getValue"),
			"recoverBeginDate":$("#recoverBeginDate").val(),
			"recoverEndDate":$("#recoverEndDate").val(),
			"recoverStatus":$("#recoverStatus").combobox("getValue")
		});
	}
	function add() {
		$.modalDialog({
			title:"卡片回收登记",
			iconCls:"icon-adds",
			width:900,
			height:310,
			shadow:false,
			closable:false,
			maximized:false,
			maximizable:false,
			href:"jsp/cardRecoverRegister/cardRecoverRegisterAddNew.jsp",
			buttons:[{
				text:"确定",
				iconCls:"icon-ok",
				handler:function(){
					saveCardRecovery();
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$.modalDialog.handler.dialog("destroy");
					$.modalDialog.handler = undefined;
				}
			}]
		});
	}
	function saveCardRecoveryIssuse(){
		var rows = $cardRecoverRegisterDataGrid.datagrid("getChecked");
		if (rows.length != 1) {
			jAlert("请勾选一条记录信息进行发放！");
			return;
		}
		if(rows[0].RECOVER_STATUS == "1") {
			jAlert("当前卡片回收状态为【已发放】！");
			return;
		}
		var params = getformdata("form");
		params.cardNo = rows[0].CARD_NO;
		params['rec.agtName'] = $('#agtName').val();
		$.messager.confirm("系统消息","您确定要发放勾选的记录吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行发放，请稍后......"});
				$.post("cardRecoverRegister/cardRecoverRegisterAction!saveCardRecoveryIssuse.action", params, function(data,status) {
					$.messager.progress("close");
					if(status == "success") {
						if (dealNull(data.status) != "0") {
							jAlert(data.errMsg);
						} else {
							jAlert("发放成功！","info",function() {
								showReport("回收卡发放",data.dealNo);
							});
							$cardRecoverRegisterDataGrid.datagrid("reload");
						}
					}else {
						$.messager.progress("close");
						jAlert("卡片发放操作发生错误！请重试！");
					}
				},"json");
			}
		});
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
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

	function exportDetail(){
		var selections = $cardRecoverRegisterDataGrid.datagrid("getSelections");
		var ids = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				ids += selections[i].ID + ",";
			}
		}
		$('#downloadcsv').attr('src','cardRecoverRegister/cardRecoverRegisterAction!exportCardRecoverRegisterInfo.action?queryType=0&rows=20000&ids=' + ids.substring(0, ids.length - 1) + '&' + $("#searchConts").serialize());
	}
</script>
<n:initpage title="卡片回收登记进行操作！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input type="text" id="certNo" class="textinput" /></td>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input type="text" id="name" class="textinput" /></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input type="text" id="cardNo" class="textinput" /></td>
						<td class="tableleft">盒号：</td>
						<td class="tableright"><input type="text" id="boxNo" class="textinput" /></td>
					</tr>
					<tr>
						<td class="tableleft">网点：</td>
						<td class="tableright"><input type="text" id="recoverBranch" class="textinput" /></td>
						<!-- <td class="tableleft">柜员：</td>
						<td class="tableright"><input type="text" id="recoverUser" class="textinput" /></td> -->
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input type="text" id="recoverBeginDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input type="text" id="recoverEndDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input type="text" id="recoverStatus" class="textinput" /></td>
					</tr>
					<tr>
						<td colspan="8" class="tableleft" style="padding-right: 20px">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false, iconCls:'icon-search'" onclick="query();">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false, iconCls:'icon-adds'" onclick="add();">新增</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false, iconCls:'icon-export'" onclick="exportDetail();">导出</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false, iconCls:'icon-save'" onclick="saveCardRecoveryIssuse();">发放</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="cardRecoverRegisterDataGrid" title="卡片回收登记信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:100px; width:100%;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
	  	<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%;">
	  		<h3 class="subtitle">代理人信息</h3>
			 <table width="100%" class="tablegrid">
				 <tr>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox  easyui-validatebox"  value="1" style="width:174px;"/> </td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" maxlength="18"/></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright"><input id="agtName" name="rec.agtName" type="text" class="textinput easyui-validatebox"   maxlength="30" /></td>
				 	<th class="tableleft">代理人联系电话：</th>
					<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
				</tr>
				<tr>
					<td class="tableleft" colspan="8">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
			 </table>
		</form>			
	</div>
	<iframe id="downloadcsv" style="display:none"></iframe>
</n:initpage>