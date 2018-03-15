<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	var cardIssuseInfoGrid;
	$(function(){
		$cardIssuseInfoGrid = createDataGrid({
			id:"cardIssuseInfo",
			url:"cardIssuse/cardIssuseAction!oneCardIssuseQuery.action",
			pagination:false,
			fitColumns:false,
			scrollbarSize:0,
			fit:false,
			singleSelect:true,
			frozenColumns:[[
				{field:"APPLY_ID",title:"申领编号",checkbox:"ture"},
		  	    {field:"CUSTOMER_ID",title:"客户编号",sortable:true},
				{field:"NAME",title:"客户姓名",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CERTTYPE",title:"证件类型",sortable:true},
				{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.13)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.07)},
				{field:"TASK_ID",title:"任务编号",sortable:true}
			]],
		  	columns:[[
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLYWAY",title:"申领方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLYSTATE",title:"申领状态",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BRCH_NAME",title:"发放网点",sortable:true},
				{field:"RELS_USER_ID",title:"发放柜员",sortable:true},
				{field:"RELS_DATE",title:"发放时间",sortable:true},
				{field:"RECV_CERT_TYPE",title:"领卡代理人证件类型",sortable:true},
				{field:"RECV_CERT_NO",title:"领卡代理人证件号码",sortable:true},
				{field:"RECV_NAME",title:"领卡代理人姓名",sortable:true},
				{field:"RECV_PHONE",title:"领卡代理人联系电话",sortable:true}
		    ]],
		    onLoadSuccess:function(data){
		      	if(data.rows.length > 0){
		      		$(this).datagrid("selectRow",0);
		      	}
	        }
		});
	});
	function cardIssuseInfoQuery(){
		if(dealNull($("#personalCertNo").val()).length == 0){
			$.messager.alert("系统消息","请输入查询条件！","error");
			return;
		}
		$cardIssuseInfoGrid.datagrid("load",{
			queryType:"0",
			"person.certNo":$("#personalCertNo").val()
		});
	}
	function cardIssuseInfoSaveinfo(){
	    var row = $cardIssuseInfoGrid.datagrid("getSelected");
	    if(row){
			$.messager.confirm("系统消息","您确定要发放所勾选的记录吗？",function(r){
	     		if(r){
	     			$.messager.progress({text:"数据处理中，请稍后...."});
	     			var params = getformdata("cardIssuseInfoAgt");
	     			params["rec.agtName"] = $("#cardIssuseInfoAgtName").val();
	     			params["taskId"] = row.TASK_ID;
	     			params["applyId"] = row.APPLY_ID;
	  				$.post("cardIssuse/cardIssuseAction!saveOneCardIssuse.action",params,function(data,status){
	  						$.messager.progress("close");
					     	if(status == "success"){
								if(data.status == "0"){
									if(data.isHk){
										jAlert("该卡为换卡，发放后可以进行【换卡转钱包】操作", "info", function(){
											showReport("个人发放",data["dealNo"]);
											$cardIssuseInfoGrid("reload");
											$("#cardIssuseInfoAgt").form("reset");
										});
									} else {
										showReport("个人发放",data["dealNo"]);
										$cardIssuseInfoGrid("reload");
										$("#cardIssuseInfoAgt").form("reset");
									}
								}else{
									$.messager.alert("系统消息",data.errMsg,"error");
								}
					     	}else{
					     		$.messager.alert("系统消息","个人发放发生错误，请重新进行操作！","error");
					     	}
					},"json");
	     		}
	     	});
	    }else{
			$.messager.alert("系统消息","请选择一条记录进行发放","error");
	    }
	}
	function readCardIssuseAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#cardIssuseInfoAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#cardIssuseInfoAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#cardIssuseInfoAgtName").val(dealNull(queryCertInfo["name"]));
	}
	
	function readSMKIssuseAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#cardIssuseInfoAgtCertType").combobox("setValue","1");
		$("#cardIssuseInfoAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#cardIssuseInfoAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<table id="cardIssuseInfo" style="height:150px;"></table>
<div>
	<form id="cardIssuseInfoAgt" method="post" class="datagrid-toolbar" style="height:100%">
		<h3 class="subtitle">代理人信息</h3>
		<table class="tablegrid">
			<tr>
				<th class="tableleft">代理人证件类型：</th>
				<td class="tableright"><input id="cardIssuseInfoAgtCertType" name="rec.agtCertType" type="text" class="textinput"/> </td>
				<th class="tableleft">代理人证件号码：</th>
				<td class="tableright"><input id="cardIssuseInfoAgtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox agt-info" validtype="idcard" maxlength="18"/></td>
				<th class="tableleft">代理人姓名：</th>
				<td class="tableright"><input id="cardIssuseInfoAgtName" name="rec.agtName" type="text" class="textinput easyui-validatebox agt-info" maxlength="30"/></td>
			</tr>
			<tr>
			    <th class="tableleft">代理人联系电话：</th>
				<td class="tableright" ><input id="cardIssuseInfoAgtTelNo" name="rec.agtTelNo" type="text" class="textinput easyui-validatebox agt-info" validtype="mobile" maxlength="11"/></td>
				<td class="tableright" colspan="4" style="padding-left: 5%">
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardIssuseAgt()">读身份证</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKIssuseAgt()">读市民卡</a>
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="cardIssuseInfoSaveinfo();">确认发放</a>
				</td>
			</tr>
		</table>
	</form>		
</div>