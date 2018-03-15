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
    <title>批量申领预览</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type="text/javascript">
	var  $personinfo;//人员列表
	$(function(){
		createCardType('cardType','100');//卡状态
		  selectByType('corpType','CORP_TYPE');//单位类型
		  selectByType('dealFlag','DEAL_FLAG');//预览申领状态 
		 //申领方式 0 社区申领   1 单位申领
		 $("#applyWay").combobox({
			width:174,
			valueField:'codeValue',
			editable:false, //不可编辑状态
		    textField:"codeName",
		    panelHeight: 'auto',//自动高度适合
		    data:[{codeValue:'2',codeName:"社区申领"},{codeValue:'1',codeName:"单位申领"},{codeValue:'3',codeName:"学校申领"}],
		    onSelect:function(node){
		 		if(node.codeValue == '2'){
		 			$('#sqapply').show();
		 			$('#dwapply').hide();
		 			$('#schapply').hide();
		 		}else if(node.codeValue == '1'){
		 			$('#sqapply').hide();
		 			$('#dwapply').show();
		 			$('#schapply').hide();
		 		}else if(node.codeValue == '3'){
		 			$('#sqapply').hide();
		 			$('#dwapply').hide();
		 			$('#schapply').show();
		 		}
		 	}
		  });
		 
		 
		 //制卡方式 0 本地制卡  1 外包制卡
		 $("#makeCardWay").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight: 'auto',
		    data:[{codeValue:'0',codeName:"本地制卡"},{codeValue:'1',codeName:"外包制卡"}]
		 });
		 
			//构造城区下拉框
			$("#regionId").combobox({ 
			    url:"commAction!getAllRegion.action",
			    editable:false, //不可编辑状态
			    cache: false,
			    panelHeight: 'auto',//自动高度适合
			    valueField:'region_Id',   
			    textField:'region_Name',
			    onLoadSuccess:function(){
			    	//1.加载成功后,设置默认
			    	var options = $("#regionId").combobox('getData');
			    	var len = options.length;
			    	if(len > 0){
			    		$(this).combobox('setValue',options[0].region_Id);
				    	$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + options[0].region_Id);
			    	}
			    },
			    onSelect:function(option){
			    	$("#townId").combobox('clear');
			    	$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + option.region_Id);
			    }
	 		}); 
			
			$("#townId").combobox({ 
			    editable:false,
			    cache: false,
			    panelHeight:'auto',
			    valueField:'town_Id',   
			    textField:'town_Name',
			    onSelect:function(node){
		    		$("#commId").combobox('clear');
		    		$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + node.town_Id);
		    	},
		    	onLoadSuccess:function(){
			 		var cys = $("#townId").combobox('getData');
			 		if(cys.length > 0){
			 			$(this).combobox('setValue',cys[0].town_Id);
			 			$("#commId").combobox('clear');
			 			$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + cys[0].town_Id);
			 		}
			    }
	 		});
			$("#commId").combobox({ 
				 editable:false,
				    cache: false,
				    panelHeight:'auto',
				    valueField:'comm_Id',   
				    textField:'comm_Name',
				    onSelect:function(node){
			    		$("#groupId").combobox('clear');
			    		$("#groupId").combobox('reload','commAction!getAllGroup.action?comm_Id=' + node.comm_Id);
			    	},
			    	onLoadSuccess:function(){
				 		var cys = $("#groupId").combobox('getData');
				 		if(cys.length > 0){
				 			$(this).combobox('setValue',cys[0].town_Id);
				 			$("#groupId").combobox('clear');
				 			$("#groupId").combobox('reload','commAction!getAllGroup.action?comm_Id=' + cys[0].comm_Id);
				 		}
				    }
	 		}); 
			
		
		 $("#groupId").combobox({ 
			    editable:false,
			    cache: false,
			    multiple:true,
			    panelHeight:'auto',
			    valueField:'group_Id',   
			    textField:'group_Name'
	 		 });
		 //学校申领
		 
		 $("#schoolId").combobox({ 
			    url:"commAction!getAllSchool.action",
			    editable:false,
			    cache: false,
			    panelHeight:'auto',
			    valueField:'school_Id',   
			    textField:'school_Name',
		    	onSelect:function(node){
		    		$("#gradeId").combobox('clear');
		    		$("#gradeId").combobox('reload','commAction!getAllGrade.action?school_Id='+node.school_Id);
		    	},
		    	onLoadSuccess:function(){
			 		var cys = $("#schoolId").combobox('getData');
			 		if(cys.length > 0){
			 			$(this).combobox('setValue',cys[0].school_Id);
			 			//$("#townId").combobox('clear');
			 			$("#gradeId").combobox('reload','commAction!getAllGrade.action?school_Id=' + cys[0].school_Id);
			 		}
			    }
	 		 }); 
			 $("#gradeId").combobox({ 
			    editable:false,
			    cache: false,
			    panelHeight:'auto',
			    valueField:'grade_Id',   
			    textField:'grade_Name',
			    onSelect:function(node){
		    		$("#classesId").combobox('clear');
		    		$("#classesId").combobox('reload','commAction!getAllGrade.action?grade_Id=' + node.grade_Id);
		    	},
		    	onLoadSuccess:function(){
			 		var cys = $("#classesId").combobox('getData');
			 		if(cys.length > 0){
			 			$(this).combobox('setValue',cys[0].grade_Id);
			 			$("#classesId").combobox('clear');
			 			$("#classesId").combobox('reload','commAction!getAllGrade.action?grade_Id=' + cys[0].grade_Id);
			 		}
			    }
	 		 });
			 $("#classesId").combobox({ 
			    editable:false,
			    cache: false,
			   // multiple:true,
			    //panelHeight:'auto',
			    valueField:'classes_Id',   
			    textField:'classes_Name'
	 		 });
		 //初始化表格
		 $personinfo = $("#personinfo");
		 $personinfo.datagrid({
			url : "/cardapply/cardApplyAction!queryApplyView.action",
			fit:true,
			witdh:900,
			height:900,
			pagination:true,
			rownumbers:true,
			border:false,
			pageList:[100,500,1000,2000],
			striped:true,
			singleSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
			      	{field:'NUM',sortable:true,checkbox:true},
			    	{field:'REGION_ID',title:'所属区域/学校名称',sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:'TOWN_ID',title:'乡镇（街道）/年级',sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:'COMM_ID',title:'社区（村）/单位名称/班级',sortable:true,width:parseInt($(this).width()*0.15)},
			    	{field:'GROUP_ID',title:'村组',sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:'MAK_NUM',title:'符合申领人员总数',sortable:false,width:parseInt($(this).width()*0.1)},
			    	{field:'TASK_NUM',title:'生成任务总数',sortable:false,width:parseInt($(this).width()*0.1)},
			    	{field:'DEAL_FLAG_NAME',title:'申领状态',sortable:false,width:parseInt($(this).width()*0.1),formatter:function(value,row){
	            		  if("0"==row.DEAL_FLAG){
								return "<font color=red>"+value+"<font>";
	            		  }else{
		            			return "<font color=green>"+value+"<font>";  
	            		  }
						}},
			    	{field:'CAT_ID',title:'操作类型',sortable:true,width:parseInt($(this).width() * 0.1),formatter:function(value,row,index){
			    		if(row.DEAL_FLAG == "0"){
			    			return "<span><a  href=\"javascript:void(0);\"  onclick=\"saveBatchApply('"+value+"')\"; ><b>快速申领</b> </a></span> &nbsp; <span><a  href=\"javascript:void(0);\"  onclick=\"delInfo('"+value+"')\"; ><b>删除 </b> </a></span>"
			    		}
			    	}}
			   ]],
			   
		 	toolbar:'#tb2',
		 	onLoadSuccess:function(data){
		 		if(dealNull(data.errMsg).length > 0){
		 			$.messager.alert('系统消息',data.errMsg,(data.status==0?"info":"error"));
		 		}
		 		var allch = $(':checkbox').get(0);
		 		if(allch){
		 			//allch.checked = false;
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
			    $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#companyNo").val()},function(data){
			    	response($.map(data,function(item){return {label:item.text,value:item.value}}));
			    });
		    },
		    select: function(event,ui){
		      	$('#companyNo').val(ui.item.label);
		        $('#companyName').val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
	      		return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#companyName").val() == ""){
			$('#companyNo').val("");
			//return;
		}
		$("#companyName").autocomplete({
	    source:function(request,response){
	        $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#companyName").val(),"queryType":"0"},function(data){
	            response($.map(data,function(item){return {label:item.value,value:item.text}}));
	        });
	    },
	    select: function(event,ui){
	      	$('#companyNo').val(ui.item.value);
	        $('#companyName').val(ui.item.label);
	        return false;
	    },
	    focus: function(event,ui){
	        return false;
	    }
	    }); 
	}
</script>
</head>
<body>
  <div class="easyui-layout" data-options="fit:true">
	  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
  			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span><span>在此您可以进行<span class="label-info"><strong>预申领</strong>操作!</span></span>
			</div>
		</div>
		<div data-options="region:'center',border:true" style="margin:0px;width:auto;padding:0px;">
			<div id="tb2">
		       <table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
			      <tr>
						<td  class="tableleft" width="8%">卡类型：</td>
						<td  class="tableright" width="15%"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;cursor:pointer;"/></td>
						<td  class="tableleft" width="8%">申领方式：</td>
						<td  class="tableright" width="15%"><input name="applyWay"  class="textinput" id="applyWay" type="text" value="2"/></td>
	                    <td  class="tableleft" width="8%">制卡方式：</td>
						<td  class="tableright" width="15%"><input name="makeCardWay" data-options="tipPosition:'right',validType:'email',invalidMessage:'选择外包制卡直接生成卡号，本地制卡不进行卡号生成。'" class="easyui-combobox easyui-validatebox" id="makeCardWay" type="text" value="1"/></td>
	                    <td  class="tableleft" width="8%">预申领状态：</td>
						<td  class="tableright" ><input name="dealFlag"  class="textinput" id="dealFlag" type="text" />&nbsp;</td>
					</tr>
					<tr id="dwapply" style="display:none;">
						<td  class="tableleft">单位编号：</td>
						<td  class="tableright"><input name="companyNo"  class="textinput" id="companyNo" type="text"  onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td  class="tableleft">单位名称：</td>
						<td  class="tableright" ><input name="companyName"  class="textinput" id="companyName" type="text"  onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td  class="tableleft">单位类型：</td>
						<td  class="tableright"><input id="corpType" type="text" class="easyui-combobox  easyui-validatebox" name="corpType" style="width:174px;cursor:pointer;"/></td>
						<td  class="tableright" colspan="2"> </td>
					</tr>
					<tr id="schapply" style="display:none;">
						<td  class="tableleft">所属学校：</td>
						<td  class="tableright"><input name="schoolNo"  class="easyui-combobox" id="schoolNo" type="text"/></td>
						<td  class="tableleft">所属年级：</td>
						<td  class="tableright" ><input name="gradeNo"  class="easyui-combobox" id="gradeNo" type="text"/></td>
						<td  class="tableleft">所在班级：</td>
						<td  class="tableright"><input id="classesId" type="text" class="easyui-combobox" name="classesId" style="width:174px;cursor:pointer;"/></td>
						<td  class="tableright" colspan="2"></td>
					</tr>
					<tr id="sqapply">
					 	<td  class="tableleft">所属区域：</td>
						<td  class="tableright"><input name="regionId"  class="easyui-combobox"  id="regionId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">乡镇（街道）：</td>
						<td  class="tableright"><input name="townId"  class="easyui-combobox" id="townId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">社区（村）：</td>
						<td  class="tableright"><input name="commId"  class="easyui-combobox easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
						<td  class="tableleft">村组：</td>
						<td  class="tableright"><input name="groupId"  class="easyui-combobox easyui-validatebox" id="groupId" type="text" style="width:174px;" /></td>
					</tr>
					<tr>
						<td class="tableleft">申领时间始：</td>
						<td class="tableright"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">申领时间止：</td>
						<td class="tableright" ><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					    <td class="tableright" colspan="4"><a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a></td>
					</tr>
			    </table>
			</div>
	  		<table id="personinfo" title="批量申领预览"></table>
		</div>
  </div>
</body>
</html>
<script type="text/javascript">
//根据选择条件进行查询
function query(){
	var away = $('#applyWay').combobox('getValue');
	if(away == '1' || away == '2'){
		if(away == '2'){//1.如果是社区申领,判断社区相关参数
			$personinfo.datagrid('reload',{
				queryType:'0',
				regionId:$('#regionId').combobox('getValue'),
				townId:$('#townId').combobox('getValue'),
				commId:$('#commId').combobox('getValue'),
				groupId:$('#groupId').combobox('getValue'),
				cardType:$('#cardType').combobox('getValue'),
				applyWay:$('#applyWay').combobox('getValue'),
				beginTime:$('#beginTime').val(),
				endTime:$('#endTime').val(),
				dealFlag:$('#dealFlag').combobox('getValue')
			});
		}else if(away == '1'){//1.如果是社区申领,判断社区相关参数
			$personinfo.datagrid('reload',
				{
					queryType:'0',
					applyWay:$('#applyWay').combobox('getValue'),
					companyNo:$('#companyNo').val(),
					beginTime:$('#beginTime').val(),
					endTime:$('#endTime').val(),
					dealFlag:$('#dealFlag').combobox('getValue'),
					cardType:$('#cardType').combobox('getValue')
				}
			);
		}else if(away == '3'){//3学校申领
			$personinfo.datagrid('reload',{
				queryType:'0',
				schoolId:$('#schoolId').combobox('getValue'),
				gradeId:$('#gradeId').combobox('getValue'),
				classesId:$('#classesId').combobox('getValue'),
				cardType:$('#cardType').combobox('getValue'),
				companyNo:$('#companyNo').val(),
				beginTime:$('#beginTime').val(),
				endTime:$('#endTime').val(),
				applyWay:$('#applyWay').combobox('getValue')
			});
		}
	}else{
		$.messager.alert('系统消息','请选择申领方式！','error');
		return;
	}
}
//保存
function saveBatchApply(CAT_ID){
	var allRows = $personinfo.datagrid('getSelections');
	var custromerIds = CAT_ID;
	$.messager.confirm('系统消息','您是否确定要进行快速申领？',function(is){
		if(is){
			//正式提交
			$.messager.progress({text : '正在生成申领数据，请稍后....'});
			$.post('/cardapply/cardApplyAction!saveBatchApplyView.action',
					{
						custromerIds:custromerIds,
						cardType:$('#cardType').combobox('getValue'),
						isDivide:'1' 
					},
					function(data,status){
						$.messager.progress('close');
							if(data.status == '0'){
								//刷新表格
							    $.messager.alert('系统消息',data.msg,'warning',function(){
							    	$personinfo.datagrid('reload',{
						    		    queryType:'0',
										cardType:$('#cardType').combobox('getValue'),
										applyWay:$('#applyWay').combobox('getValue')
										});
							    });
							   
							}else{
								$.messager.alert('系统消息',data.msg,'error');
							}
					},
			'json');
		}
	});
}
//删除
function delInfo(CAT_ID){
	var allRows = $personinfo.datagrid('getSelections');
	var custromerIds = CAT_ID;
	$.messager.confirm('系统消息','您是否确定真的删除么？',function(is){
		if(is){
			//正式提交
			$.messager.progress({text : '正在删除数据，请稍后....'});
			$.post('/cardapply/cardApplyAction!deleteInfoView.action',
					{custromerIds:custromerIds,queryType:'0'},
					function(data,status){
						$.messager.progress('close');
							if(data.status == '0'){
								//刷新表格
							    $.messager.alert('系统消息',data.msg,'warning',function(){
							    	 $personinfo.datagrid('reload',{
						    		    queryType:'0',
										cardType:$('#cardType').combobox('getValue'),
										applyWay:$('#applyWay').combobox('getValue')
										});
							    });
							}else{
								$.messager.alert('系统消息',data.msg,'error');
							}
					},
			'json');
		}
	});
}
</script>