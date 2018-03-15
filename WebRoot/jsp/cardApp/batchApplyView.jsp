<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>批量申领(新版)</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">   
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type="text/javascript">
	var  $personinfo;
	$(function(){
		createSysCode({id:"cardType",codeType:"CARD_TYPE",codeValue:"100",isShowDefaultOption:false});
		createSysCode({id:"corpType",codeType:"CORP_TYPE"});
		createSysBranch({id:"recvBrchId"});
		/* createCustomSelect({
			id:"bkvenId",
			value:"vendor_id",
			text:"vendor_name",
			table:"BASE_VENDOR",where:"state = '0'",
			isShowDefaultOption:false,
			orderby:"vendor_id asc",
			from:1,
			to:30
		}); */
		/* createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"Base_Bank",where:"bank_state = '0'",
			isShowDefaultOption:false,
			orderby:"bank_id asc",
			from:1,
			to:30
		}); */
		createLocalDataSelect({
			id:"applyWay",
		    data:[{value:'2',text:"社区申领"},{value:'1',text:"单位申领"},{value:'3',text:"学校申领"}],
		    value:"2",
		    onSelect:function(node){
		 		if(node.value == '2'){
		 			$('#sqapply').show();
		 			$('#dwapply').hide();
		 			$('#schapply').hide();
		 		}else if(node.value == '1'){
		 			$('#sqapply').hide();
		 			$('#dwapply').show();
		 			$('#schapply').hide();
		 		}else if(node.value == '3'){
		 			$('#sqapply').hide();
		 			$('#dwapply').hide();
		 			$('#schapply').show();
		 		}
		 	}
		});
		createLocalDataSelect({
			id:"makeCardWay",
		    data:[{value:"0",text:"本地制卡"},{value:"1",text:"外包制卡"}],
		    value:"1"
		});
		createRegionSelect(
			{id:"regionId",panelMaxHeight:200},
			{id:"townId"},
			{
				id:"commId",
			    onSelect:function(node){
		    		$("#groupId").combobox("clear");
		    		$("#groupId").combobox("reload","commAction!getAllGroup.action?comm_Id=" + node.comm_Id);
		    	},
		    	onLoadSuccess:function(){
			 		var cys = $("#commId").combobox("getData");
			 		if(cys.length > 0){
			 			$("#commId").combobox("setValue",cys[0].comm_Id);
			 			$("#groupId").combobox("clear");
			 			$("#groupId").combobox("reload","commAction!getAllGroup.action?comm_Id=" + cys[0].comm_Id);
			 		}
			    }
			}
		);
		$("#groupId").combobox({ 
		    editable:false,
		    cache: false,
		    multiple:false,
		    panelHeight:"auto",
		    valueField:"group_Id",   
		    textField:"group_Name"
 		});	
		$("#schoolId").combobox({ 
		    url:"commAction!getAllSchool.action",
		    editable:false,
		    cache: false,
		    panelHeight:"auto",
		    valueField:"school_Id",   
		    textField:"school_Name",
	    	onSelect:function(node){
	    		$("#gradeId").combobox("clear");
	    		$("#gradeId").combobox("reload","commAction!getAllGrade.action?school_Id="+node.school_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#schoolId").combobox("getData");
		 		if(cys.length > 0){
		 			$(this).combobox("setValue",cys[0].school_Id);
		 			$("#gradeId").combobox("reload","commAction!getAllGrade.action?school_Id=" + cys[0].school_Id);
		 		}
		    }
 		}); 
		$("#gradeId").combobox({ 
		    editable:false,
		    cache: false,
		    panelHeight:"auto",
		    valueField:"grade_Id",   
		    textField:"grade_Name",
		    onSelect:function(node){
	    		$("#classesId").combobox("clear");
	    		$("#classesId").combobox("reload","commAction!getAllGrade.action?grade_Id=" + node.grade_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#classesId").combobox("getData");
		 		if(cys.length > 0){
		 			$(this).combobox("setValue",cys[0].grade_Id);
		 			$("#classesId").combobox("clear");
		 			$("#classesId").combobox("reload","commAction!getAllGrade.action?grade_Id=" + cys[0].grade_Id);
		 		}
		    }
 		});
		$("#classesId").combobox({ 
		    editable:false,
		    cache: false,
		    valueField:"classes_Id",   
		    textField:"classes_Name"
		});
		$personinfo = $("#personinfo");
		$personinfo.datagrid({
			url:"cardapply/cardApplyAction!batchApplyView.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			pageList:[100,500,1000,2000],
			striped:true,
			singleSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
		      	{field:"NUM",sortable:true,checkbox:true},
		    	{field:"REGION_ID",title:"所属区域/学校名称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"TOWN_ID",title:"乡镇（街道）/年级",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"COMM_ID",title:"社区（村）/单位名称/班级",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"GROUP_ID",title:"村组",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"MAK_NUM",title:"符合申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)}/* 	,
		    	{field:"CAT_ID",title:"查看人员信息",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
		    		if(value == "正常"){
		    			return value;
		    		}else{
		    			return "<span><a  href=\"javascript:void(0)\" onclick=\"viewRowsOpenDlg(\"" + value + "\")\" ><b>查看</b></a></span>"
		    		}
		    	}} */
		    ]],
		 	toolbar:"#tb2",
		 	onLoadSuccess:function(data){
		 		if(dealNull(data.errMsg).length > 0){
		 			$.messager.alert("系统消息",data.errMsg,(data.status == "0" ? "info" : "error"));
		 		}
		 	}
		});
	});
	function autoCom(){
		if($("#companyNo").val() == ""){
			$("#companyName").val("");
			//return;
		}
		$("#companyNo").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#companyNo"},
		    source: function(request,response){
			    $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#companyNo").val()},function(data){
			    	response($.map(data,function(item){return {label:item.text,value:item.value}}));
			    });
		    },
		    select: function(event,ui){
		      	$("#companyNo").val(ui.item.label);
		        $("#companyName").val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
	      		return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#companyName").val() == ""){
			$("#companyNo").val("");
			//return;
		}
		$("#companyName").autocomplete({
	    source:function(request,response){
	        $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#companyName").val(),"queryType":"0"},function(data){
	            response($.map(data,function(item){return {label:item.value,value:item.text}}));
	        });
	    },
	    select: function(event,ui){
	      	$("#companyNo").val(ui.item.value);
	        $("#companyName").val(ui.item.label);
	        return false;
	    },
	    focus: function(event,ui){
	        return false;
	    }
	    }); 
	}
	function toQuery(){
		var away = $("#applyWay").combobox("getValue");
		if(away == "1" || away == "2" || away == "3"){
			if(away == "2"){
				var regionIdValue = $("#regionId").combobox("getValue");
				var townIdValue = $("#townId").combobox("getValue");
				var commValue = $("#commId").combobox("getValue");
				if(dealNull(regionIdValue) == ""){
					$.messager.alert("系统消息","请选择人员所属区域","error",function(){
						$("#regionId").combobox("showPanel");
					});
					return;
				}
				if(dealNull(townIdValue) == ""){
					$.messager.alert("系统消息","请选择人员所属乡镇（街道）","error",function(){
						$("#townId").combobox("showPanel");
					});
					return;
				}
				$personinfo.datagrid("load",{
					queryType:"0",
					regionId:$("#regionId").combobox("getValue"),
					townId:$("#townId").combobox("getValue"),
					commId:$("#commId").combobox("getValue"),
					groupId:$("#groupId").combobox("getValue"),
					cardType:$("#cardType").combobox("getValue"),
					applyWay:$("#applyWay").combobox("getValue"),
					//bkvenId:$("#bkvenId").combobox("getValue"),
					//bankId:$("#bankId").combobox("getValue"),
					beginTime:$("#beginTime").val(),
					endTime:$("#endTime").val()
				});
			}else if(away == "1"){//1.单位申领
				var companyNoValue = $("#companyNo").val();
				var corpTypeValue = $("#corpType").combobox("getValue");
				if(dealNull(companyNoValue) == ""){
					if(dealNull(corpTypeValue) == ""){
					    $.messager.alert("系统消息","单位类型不能为空！","error",function(){
					    	$("#corpType").combobox("showPanel");
					    });
						return;
					}
				}
				$personinfo.datagrid("reload",{
					queryType:"0",
					applyWay:$("#applyWay").combobox("getValue"),
					companyNo:$("#companyNo").val(),
					beginTime:$("#beginTime").val(),
					endTime:$("#endTime").val(),
					cardType:$("#cardType").combobox("getValue"),
					//bkvenId:$("#bkvenId").combobox("getValue"),
					//bankId:$("#bankId").combobox("getValue"),
					corpType:$("#corpType").combobox("getValue")
				});
			}else if(away == "3"){//3学校申领
				var schooIdValue = $("#schoolId").combobox("getValue");
				var gradeIdValue = $("#gradeId").combobox("getValue");
				if(dealNull(schooIdValue) == ""){
					$.messager.alert("系统消息","已选择学校申领，","error");
					return;
				}
				if(dealNull(gradeIdValue) == ""){
					$.messager.alert("系统消息","已选择学校申领，请选择申领人员所属乡镇（街道）","error");
					return;
				}
				$personinfo.datagrid("reload",{
					queryType:"0",
					schoolId:$("#schoolId").combobox("getValue"),
					gradeId:$("#gradeId").combobox("getValue"),
					classesId:$("#classesId").combobox("getValue"),
					cardType:$("#cardType").combobox("getValue"),
					applyWay:$("#applyWay").combobox("getValue"),
					//bkvenId:$("#bkvenId").combobox("getValue"),
					//bankId:$("#bankId").combobox("getValue"),
					beginTime:$("#beginTime").val(),
					endTime:$("#endTime").val()
				});
			}
		}else{
			$.messager.alert("系统消息","请选择申领方式！","error");
			return;
		}
	}
	//删除选择行
	function deleteRow(){
		var selectedRow = $personinfo.datagrid("getSelected");
		if(!selectedRow){
			return;
		}
		var tempindex = $personinfo.datagrid("getRowIndex",selectedRow);
		$personinfo.datagrid("deleteRow",tempindex);
		if(tempindex == 0){
			var allch = $(":checkbox").get(0);
	 		if(allch){
	 			allch.checked = false;
	 		}
		}
	}
	//迭代清空表格
	function deteteAllRows(id){
		var $tempgrid = $("#" + id);
		var allRows = $tempgrid.datagrid("getRows");
		if(allRows && allRows.length > 0){
			$tempgrid.datagrid("deleteRow",0);
			deteteAllRows(id);
		}else{
			return;
		}
	}
	//预览脱机消费对账明细
	function viewRowsOpenDlg(CAT_ID){
		var rows = $personinfo.datagrid("getChecked");
			$.modalDialog({
				title:"预览人员信息",
				iconCls:"icon-termManage",
				fit:true,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				href:"/jsp/cardApp/viewlist.jsp",
				onLoad:function(){
					viewCAT(CAT_ID,rows.GROUP_ID);
				},
				tools:[
					{
						iconCls:"icon_cancel_01",
						handler:function(){
							$.modalDialog.handler.dialog("destroy");
						    $.modalDialog.handler = undefined;
					   }
					}
				]
			});
		//}else{
			//$.messager.alert("系统消息","请选择一条记录信息进行预览！","error");
		//}
	}
	function toApply(){
		var allRows = $personinfo.datagrid("getSelections");
		var custromerIds  = "";
		var mak_num  = "";
		if(allRows){
			for(var d=0;d<allRows.length;d++){
				custromerIds += allRows[d].CAT_ID + ",";
			}
			for(var d=0;d<allRows.length;d++){
				mak_num = allRows[d].MAK_NUM;
				if(mak_num==0){
					$.messager.alert("系统消息","申领人数量为【0】，不能申领确认！","error");
					return;
				}
				mak_num="";
			}
		}
		var custromerIds = custromerIds.substring(0,custromerIds.length -1)
		if(custromerIds.length==0){
			$.messager.alert("系统消息","至少选择一行记录进行处理！","error");
			return;
		}
		if($("#recvBrchId").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择领卡网点！","error");
			return;
		}
		$.messager.confirm("系统消息","您是否确定要进行规模申领？",function(is){
			if(is){  
				//正式提交
				//setTimeout("Timeout()", 60000); 
				$.messager.progress({text : "正在生成预申领数据，请稍后...."});
				$.post("/cardapply/cardApplyAction!saveBatchApplyView.action",
						{
							selectByType:$("#corpType").combobox("getValue"),
							makeCardWay:$("#makeCardWay").combobox("getValue"),
							cardType:$("#cardType").combobox("getValue"),
							corpType:$("#corpType").combobox("getValue"),
							//bkvenId:$("#bkvenId").val(),
							//bankId:$("#bankId").val(),
							custromerIds:custromerIds,
							isDivide:"1",
							recvBrchId:$("#recvBrchId").combobox("getValue")
						},
						function(data,status){
							$.messager.progress("close");
							if(status == "success"){
								if(data.status == "0"){
									//刷新表格
								    $.messager.alert("系统消息",data.msg,"warning",function(){
								    	 $personinfo.datagrid("load",{
								    		 queryType:"0",
												regionId:$("#regionId").combobox("getValue"),
												townId:$("#townId").combobox("getValue"),
												commId:$("#commId").combobox("getValue"),
												groupId:$("#groupId").combobox("getValue"),
												cardType:$("#cardType").combobox("getValue"),
												applyWay:$("#applyWay").combobox("getValue"),
												//bkvenId:$("#bkvenId").combobox("getValue"),
												//bankId:$("#bankId").combobox("getValue"),
												corpType:$("#corpType").combobox("getValue"),
												beginTime:$("#beginTime").val(),
												endTime:$("#endTime").val()
								    	 });
								    });
								   
								}else{
									$.messager.alert("系统消息",data.msg,"error");
								}
							}else{
								$.messager.alert("系统消息","规模申领出现错误，请重试！","error");
							}
						},
				"json");
			}
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此您可以进行<span class="label-info"><strong>人员进行预申领</strong>操作！</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="margin:0px;width:auto;padding:0px;border-left:none;border-bottom:none;">
		<div id="tb2">
	       <table class="tablegrid">
		      <tr>
					<td class="tableleft" style="width:8%">卡类型：</td>
					<td class="tableright" style="width:17%"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;cursor:pointer;"/></td>
					<td class="tableleft" style="width:8%">申领方式：</td>
					<td class="tableright" style="width:17%"><input name="applyWay"  class="textinput" id="applyWay" type="text" value="2"/></td>
					<!-- <td class="tableleft" style="width:8%">申领银行：</td>
					<td class="tableright" style="width:17%"><input id="bankId" type="text" class="easyui-combobox  easyui-validatebox" name="bankId"/></td>
                    <td class="tableleft" style="width:8%">制卡厂商：</td>
					<td class="tableright" style="width:17%"><input name="bkvenId"  class="textinput" id="bkvenId" type="text" /></td> -->
					<td class="tableleft" style="width:8%">领卡网点：</td>
					<td class="tableright" style="width:17%" colspan="1"><input name="recvBrchId"  class="textinput" id="recvBrchId" type="text"/></td>
					<td class="tableleft" style="width:8%">制卡方式：</td>
					<td class="tableright" style="width:17%"><input name="makeCardWay" data-options="tipPosition:'right',validType:'email',invalidMessage:'选择外包制卡直接生成卡号，本地制卡不进行卡号生成。'" class="easyui-combobox easyui-validatebox" id="makeCardWay" type="text" value="1"/></td>
				</tr>
				<tr id="dwapply" style="display:none;">
					<td  class="tableleft">单位编号：</td>
					<td  class="tableright"><input name="companyNo"  class="textinput" id="companyNo" type="text"  onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td  class="tableleft">单位名称：</td>
					<td  class="tableright" ><input name="companyName"  class="textinput" id="companyName" type="text"  onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					<td  class="tableleft">单位类型：</td>
					<td  class="tableright"><input id="corpType" type="text" class="easyui-combobox  easyui-validatebox" name="corpType" style="width:174px;cursor:pointer;"/></td>
					<td  colspan="2">&nbsp;</td>
				</tr>
				<tr id="schapply" style="display:none;">
					<td  class="tableleft">所属学校：</td>
					<td  class="tableright"><input name="schoolId"  class="easyui-combobox" id="schoolId" type="text" style="width:174px;"/></td>
					<td  class="tableleft">所属年级：</td>
					<td  class="tableright" ><input name="gradeId"  class="easyui-combobox" id="gradeId" type="text" style="width:174px;"/></td>
					<td  class="tableleft">所在班级：</td>
					<td  class="tableright"><input id="classesId" type="text" class="easyui-combobox" name="classesId" style="width:174px;cursor:pointer;"/></td>
					<td  colspan="2">&nbsp;</td>
				</tr>
				<tr id="sqapply">
				 	<td  class="tableleft">所属区域：</td>
					<td  class="tableright"><input name="regionId"  class="textinput"  id="regionId"  type="text" style="width:174px;"/></td>
					<td  class="tableleft">乡镇（街道）：</td>
					<td  class="tableright"><input name="townId"  class="textinput" id="townId"  type="text" style="width:174px;"/></td>
					<td  class="tableleft">社区（村）：</td>
					<td  class="tableright"><input name="commId"  class="textinput easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
					<td  class="tableleft">村组：</td>
					<td  class="tableright"><input name="groupId"  class="textinput easyui-validatebox" id="groupId" type="text" style="width:174px;" /></td>
				</tr>
				<tr>
				    <td class="tableleft" colspan="8">
				    	<input type="hidden" id="beginTime" name="beginTime" value="">
				    	<input type="hidden" id="endTime" name="endTime" value="">
				    	<!-- <input type="checkbox" id="isDivide" name="isDivide" value="0" /><span id="ksslmsg" style="height:100%">快速申领 </span> &nbsp;&nbsp; -->
				    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQuery()">查询</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="toApply()">申领确认</a>
						<a href="javascript:void(0);" class="easyui-linkbutton"  data-options="plain:false,iconCls:'icon-remove'" onclick="deleteRow()">删除</a>
				    </td>
				</tr>
		    </table>
		</div>
  		<table id="personinfo" title="批量申领预览"></table>
	</div>
</body>
</html>
